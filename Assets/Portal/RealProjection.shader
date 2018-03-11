// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Rewind/RealProjection"  
{
	Properties { 
 		CubemapTop("CubemapTop", 2D) = "white"
 		CubemapBottom("CubemapBottom", 2D) = "black"
 		CubemapLeft("CubemapLeft", 2D) = "white"
 		CubemapRight("CubemapRight", 2D) = "black"
 		CubemapFront("CubemapFront", 2D) = "white"
 		CubemapBack("CubemapBack", 2D) = "black"
 		CameraWorldPos("CameraWorldPos",VECTOR) = (0,0,0,0)
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
             
             float3 Camera = CameraWorldPos;
             float3 VertWorldPos = mul(unity_ObjectToWorld, v.vertex);
             OUT.vectortocamera = VertWorldPos - Camera;
             return OUT;
         }
         
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
			//return float4( IN.worldpos.x,  IN.worldpos.y,  IN.worldpos.z, 1 );
			
		
			float3 VectorToCamera = normalize(IN.worldpos - CameraWorldPos);
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