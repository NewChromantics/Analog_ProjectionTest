// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Analog/PortalRender"  
{
	Properties { 
 		CubemapTop("CubemapTop", 2D) = "white"
 		CubemapBottom("CubemapBottom", 2D) = "black"
 		CubemapLeft("CubemapLeft", 2D) = "white"
 		CubemapRight("CubemapRight", 2D) = "black"
 		CubemapFront("CubemapFront", 2D) = "white"
 		CubemapBack("CubemapBack", 2D) = "black"
 		CameraWorldPos("CameraWorldPos",VECTOR) = (0,0,0,0)
 		
 		WorldTopLeft("WorldTopLeft", VECTOR) = (-1,-1,0,0)
 		WorldTopRight("WorldTopRight", VECTOR) = (-1,-1,0,0)
 		WorldBottomLeft("WorldBottomLeft", VECTOR) = (-1,-1,0,0)
 		WorldBottomRight("WorldBottomRight", VECTOR) = (-1,-1,0,0)


		ObjectToWorldMatrix_0("ObjectToWorldMatrix_0", VECTOR ) = (0,0,0,0)
		ObjectToWorldMatrix_1("ObjectToWorldMatrix_1", VECTOR ) = (0,0,0,0)
		ObjectToWorldMatrix_2("ObjectToWorldMatrix_2", VECTOR ) = (0,0,0,0)
		ObjectToWorldMatrix_3("ObjectToWorldMatrix_3", VECTOR ) = (0,0,0,0)
	 }
	 	
 	 SubShader 
 	{ 
 		Tags 
		 { 
		 "RenderType"="Opaque"
		 }
		 Cull Off
		
     Pass {
         CGPROGRAM
         #pragma vertex vert
         #pragma fragment frag
          //	gr: avoid crashes on some windows machines by only compiling specific targets
    	#pragma only_renderers d3d11 opengl
    
    
         #include "UnityCG.cginc"
 
		sampler2D CubemapTop;
		sampler2D CubemapBottom;
		sampler2D CubemapLeft;
		sampler2D CubemapRight;
		sampler2D CubemapFront;
		sampler2D CubemapBack;
		float3 CameraWorldPos;
		
		float3 WorldTopLeft;
		float3 WorldTopRight;
		float3 WorldBottomLeft;
		float3 WorldBottomRight;

		float4 ObjectToWorldMatrix_0;
		float4 ObjectToWorldMatrix_1;
		float4 ObjectToWorldMatrix_2;
		float4 ObjectToWorldMatrix_3;
		float4x4 PortalToWorldMatrix;

			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			
			/*
 
 	//	gr; does this exist with blit?
         v2f vert(appdata_t v) {
             v2f OUT;
             OUT.uv = v.uv;
             OUT.screenpos = mul(UNITY_MATRIX_MVP, v.vertex);
             OUT.worldpos = mul(_Object2World, v.vertex);
             
             float3 Camera = CameraWorldPos;
             float3 VertWorldPos = mul(_Object2World, v.vertex);
             OUT.vectortocamera = VertWorldPos - Camera;
             return OUT;
         }
         */
         
         //	gr: const int's were all 0 on DX
         #define TOP 0
         #define BOTTOM 1
         #define LEFT 2
         #define RIGHT 3
         #define FRONT 4
         #define BACK 5

         //	returns index and xy sample
         int GetCubemapIndex(float3 View,out float2 st)
         {
         	//	gr: if this appears to be getting the wrong angle (left/right/forward/back), it's because the screens need to face the same direction as the actor
         
         	float x = View.x;
         	float y = View.y;
         	float z = View.z;
         	float ax = abs(x);
         	float ay = abs(y);
         	float az = abs(z);
    
         	
			if (ax >ay && ax > az && x>=0)
			{
				st.x = -(z / ax);
				st.y = -y / ax;
				
				return RIGHT;
			}
			else if (ax >ay && ax > az && x<0)
			{
				st.x = (z / ax);
				st.y = -y / ax;
				
				return LEFT;
			}
			else if (ay > ax && ay > az && y>=0 )
			{
				st.x = x / ay;
				st.y = z / ay;
				
				return TOP;
			}
			else if (ay > ax && ay > az && y<0 )
			{
				st.x = x / ay;
				st.y = -(z / ay);
				
				return BOTTOM;
			}
			else if ( z >= 0 )
			{
				st.x = x / az;
				st.y = -y / az;
				return FRONT;
			}
			else
			{
				st.x = -(x / az);
				st.y = -y / az;
				return BACK;
			}
			
			return -1;
        }
         
          
        float4 SampleTexCube(float3 View)
        {
        	float2 st;
        	View = normalize(View);
        	int TextureIndex = GetCubemapIndex( View, st );
        	//return float4(View.x, View.y,View.z,1);
        	//return float4(st.x,st.y,0,1);
        	st += float2(1,1);
        	st /= float2(2,2);
        	st.y = 1 - st.y;
        
        	bool RenderFaceDebug = false;
        	if ( RenderFaceDebug )
        	{
        		if ( TextureIndex == TOP )		return float4( 1, 0, 0, 1 );//tex2D( CubemapTop, st );
        		if ( TextureIndex == BOTTOM )	return float4( 0, 1, 0, 1 );//tex2D( CubemapBottom, st );
        		if ( TextureIndex == LEFT )		return float4( 0, 0, 1, 1 );//tex2D( CubemapLeft, st );
        		if ( TextureIndex == RIGHT )	return float4( 1, 1, 0, 1 );//tex2D( CubemapRight, st );
        		if ( TextureIndex == FRONT )	return float4( 0, 1, 1, 1 );//tex2D( CubemapFront, st );
        		if ( TextureIndex == BACK )		return float4( 1, 0, 1, 1 );//tex2D( CubemapBack, st );
			}        	
           	if ( TextureIndex == TOP )		return tex2D( CubemapTop, st );
        	if ( TextureIndex == BOTTOM )	return tex2D( CubemapBottom, st );
        	if ( TextureIndex == LEFT )		return tex2D( CubemapLeft, st );
        	if ( TextureIndex == RIGHT )	return tex2D( CubemapRight, st );
        	if ( TextureIndex == FRONT )	return tex2D( CubemapFront, st );
        	if ( TextureIndex == BACK )		return tex2D( CubemapBack, st );
    	
        		
			return float4( 1, 0, 1, 1 );
		}

		float4 frag(v2f IN) : COLOR 
		{
			bool RenderUv = false;
			if  ( RenderUv )
				return float4( IN.uv.x, IN.uv.y, 1, 1 );
		
			//	calc world pos
			float2 LocalPos2 = float2( 1-IN.uv.x, 1-IN.uv.y );
			LocalPos2 -= 0.5f;
			LocalPos2 *= 10.0f;
			float4 LocalPos = float4( LocalPos2.x, 0, LocalPos2.y, 1);
			
			float4x4 ObjectToWorldMatrix = PortalToWorldMatrix;
			//float4x4 ObjectToWorldMatrix = float4x4( ObjectToWorldMatrix_0, ObjectToWorldMatrix_1, ObjectToWorldMatrix_2, ObjectToWorldMatrix_3 );
			//float4x4 ObjectToWorldMatrix = float4x4( 1,0,0,0,	0,1,0,0,	0,0,1,0,	0,0,0,1 );
			
			float3 WorldPos = mul( ObjectToWorldMatrix, LocalPos ).xyz;
			//float3 WorldPos = LocalPos;
			
			
			bool RenderLocalPos = false;
			if ( RenderLocalPos )
			{
				//LocalPos += 1;
				//LocalPos /= 2;
				return float4( LocalPos.x, LocalPos.y, LocalPos.z, 1 );
			}
			
			bool RenderWorldPos = false;
			if ( RenderWorldPos )
			{
				///WorldPos += 1;
				//WorldPos /= 2;
				return float4( WorldPos.x, WorldPos.y, WorldPos.z, 1 );
			}
			//return float4( ObjectToWorldMatrix[0].x, ObjectToWorldMatrix[0].y, ObjectToWorldMatrix[0].z, 1 );
		
		
			//return float4( IN.worldpos.x,  IN.worldpos.y,  IN.worldpos.z, 1 );
			
		
			float3 VectorToCamera = normalize(WorldPos - CameraWorldPos);
			/*
			float f = VectorToCamera.y;
			if ( f < 0 )
			{
				return float4(1,0,0,1);
			}
			return float4(0,0,1,1);
			*/
		
			bool RenderViewDir = false;
			if ( RenderViewDir )
			{
				VectorToCamera += 1.0f;
				VectorToCamera /= 2.0f;
				return float4( VectorToCamera.x, VectorToCamera.y, VectorToCamera.z, 1 );
			}
			
			//return float4( CameraWorldPos.x, CameraWorldPos.y, CameraWorldPos.z, 1 );
			//return float4( IN.vectortocamera.x,  IN.vectortocamera.y,  IN.vectortocamera.z, 1 );
			float4 Colour = SampleTexCube(VectorToCamera);
			return Colour;
         }
         ENDCG 
     }
    }
 
 FallBack "Diffuse"
 }