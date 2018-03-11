// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Rewind/RealProjectionDebug"  
{
	Properties { 
 		//_CubeTex("Cubemap", CUBE) = "" {} 
 		_CameraPosition("CameraWorldPos",VECTOR) = (0,0,0,0)
 		ColourScalar("ColourScalar", Range(0,1)) = 1
 		FrustumCount("FrustumCount", Int ) = 0
 		
 		Frustum00("Frustum00", VECTOR ) = (0,0,0,0)
 		Frustum01("Frustum01", VECTOR ) = (0,0,0,0)
 		Frustum02("Frustum02", VECTOR ) = (0,0,0,0)
 		Frustum03("Frustum03", VECTOR ) = (0,0,0,0)
 		
 
 		Frustum10("Frustum10", VECTOR ) = (0,0,0,0)
 		Frustum11("Frustum11", VECTOR ) = (0,0,0,0)
 		Frustum12("Frustum12", VECTOR ) = (0,0,0,0)
 		Frustum13("Frustum13", VECTOR ) = (0,0,0,0)

 		Frustum20("Frustum20", VECTOR ) = (0,0,0,0)
 		Frustum21("Frustum21", VECTOR ) = (0,0,0,0)
 		Frustum22("Frustum22", VECTOR ) = (0,0,0,0)
 		Frustum23("Frustum23", VECTOR ) = (0,0,0,0)

 		Frustum30("Frustum30", VECTOR ) = (0,0,0,0)
 		Frustum31("Frustum31", VECTOR ) = (0,0,0,0)
 		Frustum32("Frustum32", VECTOR ) = (0,0,0,0)
 		Frustum33("Frustum33", VECTOR ) = (0,0,0,0)

 		Frustum40("Frustum40", VECTOR ) = (0,0,0,0)
 		Frustum41("Frustum41", VECTOR ) = (0,0,0,0)
 		Frustum42("Frustum42", VECTOR ) = (0,0,0,0)
 		Frustum43("Frustum43", VECTOR ) = (0,0,0,0)

		Frustum50("Frustum50", VECTOR ) = (0,0,0,0)
 		Frustum51("Frustum51", VECTOR ) = (0,0,0,0)
 		Frustum52("Frustum52", VECTOR ) = (0,0,0,0)
 		Frustum53("Frustum53", VECTOR ) = (0,0,0,0)
 		
	 }
	 	
 	 SubShader 
 	{ 
 		Tags 
		 { 
		 "RenderType"="Opaque+1" 
		 }
		 Cull Back

     Pass {
         CGPROGRAM
// Upgrade NOTE: excluded shader from DX11, Xbox360, OpenGL ES 2.0 because it uses unsized arrays
#pragma exclude_renderers d3d11 xbox360 gles
         #pragma vertex vert
         #pragma fragment frag
         //	gr: avoid crashes on some windows machines by only compiling specific targets
  	#pragma only_renderers d3d11 opengl
      
         #include "UnityCG.cginc"
 
		float3 _CameraPosition;
 
		int FrustumCount;
		float ColourScalar;
		
		half4 Frustum00, Frustum01, Frustum02, Frustum03;
		half4 Frustum10, Frustum11, Frustum12, Frustum13;
		half4 Frustum20, Frustum21, Frustum22, Frustum23;
		half4 Frustum30, Frustum31, Frustum32, Frustum33;
		half4 Frustum40, Frustum41, Frustum42, Frustum43;
		half4 Frustum50, Frustum51, Frustum52, Frustum53;


         struct appdata_t {
             float4 vertex : POSITION;
             float3 normal : NORMAL;
         };
 
         struct v2f {
             float4 screenpos : POSITION;
             float3 vectortocamera : TEXCOORD0;
             float4 worldpos : TEXCOORD1;
         };
 
         v2f vert(appdata_t v) {
             v2f OUT;
             OUT.screenpos = UnityObjectToClipPos(v.vertex);
             OUT.worldpos = mul(unity_ObjectToWorld, v.vertex);
             
             float3 CameraWorldPos = _CameraPosition;
             float3 VertWorldPos = mul(unity_ObjectToWorld, v.vertex);
             OUT.vectortocamera = VertWorldPos - CameraWorldPos;
             return OUT;
         }
         
         bool PointInPlane(float3 WorldPos,half4 Plane)
         {
         	float Mag = dot( Plane.xyz, WorldPos );
         	float Distance = Mag + Plane.w;
         	return Distance > 0;
         }
         
         bool PointInFrustum(float3 WorldPos,half4x4 Frustum)
         {
         	bool Inside = true;
         	Inside = Inside && PointInPlane( WorldPos, Frustum[0] );
         	Inside = Inside && PointInPlane( WorldPos, Frustum[1] );
         	Inside = Inside && PointInPlane( WorldPos, Frustum[2] );
         	Inside = Inside && PointInPlane( WorldPos, Frustum[3] );
         	return Inside;
         }
 		int LeftShit(int Mask)
		{
			return Mask * 2;
		}
		int RightShift(int Mask,int Iterations=1)
		{
			for ( int i=0;	i<Iterations;	i++ )
				Mask = Mask / 2;
			return Mask;
		}
		int BIT(int BitIndex)
		{
			return (BitIndex==0) ? 1 : BitIndex * 2;
		}
		int OR(int a,int b)
		{
		//	gr; only works if bit doesn't already exist
			return a+b;
		}
		bool HASBIT(int Mask,int BitIndex)
		{
			Mask = RightShift( Mask, BitIndex );
			int d = Mask% 2;
			return d == 1;
		}

 		int GetInFrustumBit(int FrustumIndex,float3 WorldPosition)
 		{
 			if ( FrustumIndex >= FrustumCount )
	 			return 0;

			bool Inside = false;
		half4x4 Frustum0 = half4x4( Frustum00, Frustum01, Frustum02, Frustum03 );
		
		half4x4 Frustum1 = half4x4( Frustum10, Frustum11, Frustum12, Frustum13 );
		half4x4 Frustum2 = half4x4( Frustum20, Frustum21, Frustum22, Frustum23 );
		half4x4 Frustum3 = half4x4( Frustum30, Frustum31, Frustum32, Frustum33 );
		half4x4 Frustum4 = half4x4( Frustum40, Frustum41, Frustum42, Frustum43 );
		half4x4 Frustum5 = half4x4( Frustum50, Frustum51, Frustum52, Frustum53 );
		
			half4x4 mtx = Frustum0;
			
			if ( FrustumIndex == 0 )	mtx = Frustum0;
			if ( FrustumIndex == 1 )	mtx = Frustum1;
			if ( FrustumIndex == 2 )	mtx = Frustum2;
			if ( FrustumIndex == 3 )	mtx = Frustum3;
			if ( FrustumIndex == 4 )	mtx = Frustum4;
			if ( FrustumIndex == 5 )	mtx = Frustum5;

			if ( !PointInFrustum( WorldPosition, mtx ) )
				return 0;
			return BIT(FrustumIndex);
		}	
		

		float4 frag(v2f IN) : COLOR 
		{
			float4 Colour = float4(0,0,0,1);
	
			half4 DebugColours[] = 
			{
				half4(0,0,1,1),
				half4(1,0,0,1),
				half4(1,1,0,1),
				half4(0,1,0,1),
				half4(0,1,1,1),
				half4(0,0,1,1),
				half4(1,0,1,1),
			};
			
			//	count overlapping frustums
			int FrustumCount = 0;
			FrustumCount += GetInFrustumBit(0,IN.worldpos);
			FrustumCount += GetInFrustumBit(1,IN.worldpos);
			FrustumCount += GetInFrustumBit(2,IN.worldpos);
			FrustumCount += GetInFrustumBit(3,IN.worldpos);
			FrustumCount += GetInFrustumBit(4,IN.worldpos);
			FrustumCount += GetInFrustumBit(5,IN.worldpos);

			Colour += ColourScalar * DebugColours[FrustumCount];

			return Colour;
			
         }
         ENDCG 
     }
    }
 
 FallBack "Diffuse"
 }