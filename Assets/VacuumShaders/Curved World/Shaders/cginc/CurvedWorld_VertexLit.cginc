#ifndef VACUUM_CURVEDWORLD_VERTEXLIT_CGINC
#define VACUUM_CURVEDWORLD_VERTEXLIT_CGINC


#include "UnityCG.cginc"
#include "../cginc/CurvedWorld_Base.cginc"


#include "../cginc/CurvedWorld_RangeFade.cginc"
////////////////////////////////////////////////////////////////////////////
//																		  //
//Variables 															  //
//																		  //
////////////////////////////////////////////////////////////////////////////
sampler2D _MainTex;
uniform float4 _MainTex_ST;
fixed2 _V_CW_MainTex_Scroll;
fixed4 _Color;

fixed _V_CW_IncludeVertexColor;

#ifdef V_CW_CUTOUT
	half _Cutoff;
#endif

#ifdef V_CW_RIM
	fixed4 _V_CW_Rim_Color;
	fixed  _V_CW_Rim_Bias;
#endif



////////////////////////////////////////////////////////////////////////////
//																		  //
//Struct    															  //
//																		  //
////////////////////////////////////////////////////////////z////////////////
struct v2f  
{  
	float4 pos : SV_POSITION;
	float2 uv : TEXCOORD0;	

	#ifdef V_CW_VERTEX_LIGHTMAP
		half2 lm : TEXCOORD1;
	#else
		fixed4 diff : TEXCOORD1;
	#endif		

	#ifdef V_CW_RIM
		half rim : TEXCOORD2; 
	#endif

	fixed4 color : COLOR;

	#ifdef V_CW_FOG
		UNITY_FOG_COORDS(3)  
	#endif		

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO


	//Curved World Distance Fade
	CURVEDWORLD_RANGE_FADE_COORDINATE(4)
};


////////////////////////////////////////////////////////////////////////////
//																		  //
//Vertex    															  //
//																		  //
////////////////////////////////////////////////////////////z////////////////
v2f vert (appdata_full v) 
{   
	UNITY_SETUP_INSTANCE_ID(v);
	v2f o;
	UNITY_INITIALIZE_OUTPUT(v2f,o); 
	UNITY_TRANSFER_INSTANCE_ID(v, o);
	UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);


	//Curved World Distance Fade
	CURVEDWORLD_RANGE_FADE_SETUP(o,v.vertex)

	//Curved World Transform
	#ifdef V_CW_VERTEX_LIGHTMAP
		V_CW_TransformPoint(v.vertex);
	#else
		V_CW_TransformPointAndNormal(v.vertex, v.normal, v.tangent);
	#endif


	o.pos = UnityObjectToClipPos(v.vertex); 
	o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
	o.uv += _V_CW_MainTex_Scroll.xy * _Time.x;
				

	#ifdef V_CW_VERTEX_LIGHTMAP
		o.lm = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
	#else
		float4 lighting = float4(ShadeVertexLightsFull(v.vertex, v.normal, 4, true), 1);
		o.diff = lighting;
	#endif

	
	o.color = v.color;

	#ifdef V_CW_RIM
		half rim = saturate(dot (normalize(v.normal), normalize(ObjSpaceViewDir(v.vertex))) + _V_CW_Rim_Bias);
		o.rim = rim * rim;
	#endif	
	
	#ifdef V_CW_FOG		
		UNITY_TRANSFER_FOG(o,o.pos); 
	#endif

	return o; 
}


////////////////////////////////////////////////////////////////////////////
//																		  //
//Fragment    															  //
//																		  //
////////////////////////////////////////////////////////////////////////////
fixed4 frag (v2f i) : SV_Target 
{

	fixed4 c = tex2D (_MainTex, i.uv) * _Color;	


	//Curved World Distance Fade
	#if defined(V_CW_CUTOUT) || defined(V_CW_TRANSPARENT)
		CURVEDWORLD_RANGE_FADE_CALCULATE(i)
	#endif


	#if defined(V_CW_CUTOUT)
		clip(c.a - _Cutoff - CURVEDWORLD_RANGE_FADE_VALUE);	
	#endif

	#ifdef V_CW_VERTEX_LIGHTMAP
		fixed4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lm); 
		half3 lm = DecodeLightmap(bakedColorTex);

		c.rgb *= lm.rgb;
	#else
		c *= i.diff;
	#endif


	//Vertex Color
	c.rgb *= lerp(fixed4(1, 1, 1, 1), i.color, _V_CW_IncludeVertexColor);

	#ifdef V_CW_RIM
		c.rgb = lerp(_V_CW_Rim_Color.rgb, c.rgb, i.rim);
	#endif
				

	#ifdef V_CW_FOG
		#ifdef V_CW_VERTEX_LIGHTMAP
			UNITY_APPLY_FOG_COLOR(i.fogCoord, c, fixed4(0,0,0,0)); // fog towards black due to LM blend mode
		#else
			UNITY_APPLY_FOG(i.fogCoord, c); 
		#endif
	#endif


	//Curved World Distance Fade
	#if defined(V_CW_TRANSPARENT)
		c *= 1 - CURVEDWORLD_RANGE_FADE_VALUE;
	#endif

	
	#if defined(V_CW_TRANSPARENT) || defined(V_CW_CUTOUT)
		//Empty
	#else
		UNITY_OPAQUE_ALPHA(c.a);
	#endif

	return c;
} 

#endif 
