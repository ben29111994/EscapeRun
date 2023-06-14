Shader "Hidden/VacuumShaders/Curved World/ShadowCaster Cutout" 
{
	Properties 
	{
		//Albedo
		[CurvedWorldLargeLabel] V_CW_Label_Albedo("Albedo", float) = 0	
		_Color("  Color", color) = (1, 1, 1, 1)
		_MainTex ("  Map (RGB) Trans (A)", 2D) = "white" {}
		[CurvedWorldUVScroll] _V_CW_MainTex_Scroll("    ", vector) = (0, 0, 0, 0)

		//Cutoff
		[CurvedWorldLargeLabel] V_CW_Label_Cutoff("Cutout", float) = 0	
		_Cutoff ("  Alpha cutoff", Range(0,1)) = 0.5	

		[CurvedWorldRangeFade] V_CW_RangeFadeDrawer("Range Fade", float) = 0
	}

	SubShader     
	{		  		  
		// Pass to render object as a shadow caster
		Pass 
		{
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }
		
			CGPROGRAM
			#pragma vertex vert   
			#pragma fragment frag
#pragma multi_compile_instancing
			#pragma multi_compile_shadowcaster 
			#include "UnityCG.cginc"
				 

			#pragma shader_feature _ V_CW_RANGE_FADE
			#define V_CW_CUTOUT

			#include "../cginc/CurvedWorld_Base.cginc"
			#include "../cginc/CurvedWorld_RangeFade.cginc"
				  


		    uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform fixed _Cutoff;
			uniform fixed4 _Color;

			struct v2f 
			{ 
				V2F_SHADOW_CASTER;
				float2  uv : TEXCOORD1;
				UNITY_VERTEX_OUTPUT_STEREO

				//Curved World Distance Fade
				CURVEDWORLD_RANGE_FADE_COORDINATE(2)
			};

			v2f vert( appdata_base v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				
				//Curved World Distance Fade
				CURVEDWORLD_RANGE_FADE_SETUP(o, v.vertex)

				V_CW_TransformPoint(v.vertex);


				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				return o;
			}

			float4 frag( v2f i ) : SV_Target
			{
				CURVEDWORLD_RANGE_FADE_CALCULATE(i)


				fixed4 texcol = tex2D( _MainTex, i.uv);
				clip( texcol.a*_Color.a - _Cutoff - CURVEDWORLD_RANGE_FADE_VALUE);

				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG

		} //Pass
	} //SubShader
}
