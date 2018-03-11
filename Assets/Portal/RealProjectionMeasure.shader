// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Rewind/RealProjectionMeasure"  
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
             float4 worldpos : TEXCOORD1;
         };
 
         v2f vert(appdata_t v) {
             v2f OUT;
             OUT.screenpos = UnityObjectToClipPos(v.vertex);
             OUT.worldpos = mul(unity_ObjectToWorld, v.vertex);
             return OUT;
         }
         
         bool NearZero(float x,float NearZeroTolerance)
         {
         	float Major = 0.f;
         	//	mod doesn't work with negative numbers
         	float Minor = modf( x+1000.0f, Major );
         	if ( Minor > 1-NearZeroTolerance || Minor < NearZeroTolerance )
         		return true;
         	return false;
      	}
      
		float4 frag(v2f IN) : COLOR 
		{
			//	scale to specify grid distance
			float GridDistance = 0.5f;
			float GridTolerance = (1.0f/GridDistance) * 0.01f;
			float3 WorldPos = IN.worldpos / GridDistance;
		
			float3 Colour = float3( 0,0,0 );
			if ( NearZero(WorldPos.x,GridTolerance) )	Colour.x = 1;
			if ( NearZero(WorldPos.y,GridTolerance) )	Colour.y = 1;
			if ( NearZero(WorldPos.z,GridTolerance) )	Colour.z = 1;
			return float4( Colour.x, Colour.y, Colour.z, 1 );
	     }
         ENDCG 
     }
    }
 
 FallBack "Diffuse"
 }