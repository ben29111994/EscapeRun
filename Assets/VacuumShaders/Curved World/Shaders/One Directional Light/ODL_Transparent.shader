// VacuumShaders 2019


Shader "Hidden/VacuumShaders/Curved World/One Directional Light/Transparent/Texture"
{
	Properties 
	{
		[CurvedWorldGearMenu] V_CW_Label_Tag("", float) = 0
		[CurvedWorldLabel] V_CW_Label_UnityDefaults("Default Visual Options", float) = 0


		//Modes
		[CurvedWorldLargeLabel] V_CW_Label_Modes("Modes", float) = 0	
		[CurvedWorldRenderingMode] V_CW_Rendering_Mode("  Rendering", float) = 0	
		[CurvedWorldTextureMixMode] V_CW_Texture_Mix_Mode("  Texture Mix", float) = 0	

		//Albedo
		[CurvedWorldLargeLabel] V_CW_Label_Albedo("Albedo", float) = 0	
		_Color("  Color", color) = (1, 1, 1, 1)
		_MainTex ("  Map (RGB) RefStr, Gloss & Trans (A)", 2D) = "white" {}
		[CurvedWorldUVScroll] _V_CW_MainTex_Scroll("    ", vector) = (0, 0, 0, 0)

		

		//Curved World
		[CurvedWorldLabel] V_CW_Label_UnityDefaults("Unity Advanced Rendering Options", float) = 0

		[HideInInspector] _V_CW_UnityAmbient("", float) = 1
		[HideInInspector] _V_CW_PerVertexLights("", float) = 1

		[HideInInspector] _V_CW_IncludeVertexColor("", float) = 0

		[HideInInspector] _V_CW_Rim_Color("", color) = (1, 1, 1, 1)
		[HideInInspector] _V_CW_Rim_Bias("", Range(-1, 1)) = 0.2
		[HideInInspector] _V_CW_Rim_Power("", Range(0.5, 8.0)) = 3
		
		[HideInInspector] _EmissionMap("", 2D) = "white"{}
		[HideInInspector] [HDR] _EmissionColor("", color) = (1, 1, 1, 1)	

		[HideInInspector] _V_CW_IBL_Intensity("", float) = 1
		[HideInInspector] _V_CW_IBL_Contrast("", float) = 1 
		[HideInInspector] _V_CW_IBL_Cube("", cube ) = ""{}  

		[HideInInspector] _V_CW_ReflectColor("", color) = (1, 1, 1, 1)
		[HideInInspector] _V_CW_ReflectStrengthAlphaOffset("", Range(-1, 1)) = 0
		[HideInInspector] _V_CW_Cube("", Cube) = "_Skybox"{}	
		[HideInInspector] _V_CW_Fresnel_Bias("", Range(-1, 1)) = 0

		[HideInInspector] _V_CW_Specular_Intensity("", Range(0, 5)) = 1		
		[HideInInspector] _V_CW_SpecularOffset("", Range(-0.25, 0.25)) = 0
		[HideInInspector] _V_CW_Specular_Lookup("", 2D) = "black"{}
		
		[HideInInspector] _V_CW_NormalMapStrength("", float) = 1
		[HideInInspector] _V_CW_NormalMap("", 2D) = "bump" {}
		[HideInInspector] _V_CW_NormalMap_UV_Scale ("", float) = 1

		[HideInInspector] _V_CW_SecondaryNormalMap("", 2D) = ""{}
		[HideInInspector] _V_CW_SecondaryNormalMap_UV_Scale("", float) = 1

		[HideInInspector] _V_CW_LightRampTex("", 2D) = "grey"{}
	}

	
	SubShader 
	{
		Tags { "Queue"="Transparent" 
		       "IgnoreProjector"="True" 
			   "RenderType"="Transparent" 
			   "CurvedWorldTag"="One Directional Light/Transparent/Texture" 
			   "CurvedWorldNoneRemoveableKeywords"="" 
			   "CurvedWorldAvailableOptions"="V_CW_USE_LIGHT_RAMP_TEXTURE;V_CW_REFLECTIVE;_EMISSION;V_CW_RIM;V_CW_FOG;_NORMALMAP;V_CW_SPECULAR_LOOKUP;V_CW_UNITY_AMBIENT;V_CW_PERVERTEX_LIGHT;VERTEX_COLOR;V_CW_RANGE_FADE;" 
			 } 
		LOD 100
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha 
		     

		//PassName "FORWARD" 
		Pass
	    {
			Name "FORWARD"
			Tags { "LightMode" = "ForwardBase" } 

			CGPROGRAM       
			#pragma vertex vert  
	    	#pragma fragment frag  
#pragma multi_compile_instancing
			#pragma multi_compile_fwdbasealpha noshadow nodirlightmap nodynlightmap
						       

 
 
 
			#pragma shader_feature _ V_CW_REFLECTIVE
			 
			#pragma shader_feature _ _EMISSION
			#pragma shader_feature _ V_CW_RIM
	
			#pragma shader_feature _ _NORMALMAP
			#pragma shader_feature _ V_CW_SPECULAR

			#pragma shader_feature _ V_CW_USE_LIGHT_RAMP_TEXTURE

			#pragma shader_feature _ V_CW_RANGE_FADE
			#pragma shader_feature _ V_CW_FOG
			#ifdef V_CW_FOG
				#pragma multi_compile_fog
			#endif   

			
			#define V_CW_TRANSPARENT

			#include "../cginc/CurvedWorld_ForwardBase.cginc" 

			
			ENDCG    
			 
		} //Pass   		  
		  		
	} //SubShader


	Fallback "Hidden/VacuumShaders/Curved World/VertexLit/Transparent" 
	CustomEditor "CurvedWorld_Material_Editor"
} //Shader
