Shader "Hidden/VacuumShaders/Curved World/Outline" 
{
	Properties 
	{
		_V_CW_OutlineColor ("Outline Color", Color) = (0,0,0,1)
		_V_CW_OutlineWidth ("Outline width", Float) = .005

		[CurvedWorldBooleanToggle] _V_CW_OutlineSizeIsFixed("Fixed Size", float) = 0
	}

	SubShader     
	{		  		  
		Tags{ "RenderType" = "Opaque" }

		//PassName "OUTLINE" 
		Pass  
		{ 
			Name "OUTLINE"
			Tags{ "LightMode" = "Always" }

			Cull Front 
			ZWrite On 
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha
			 
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag  
#pragma multi_compile_instancing

 
						 			   
			#pragma shader_feature _ V_CW_FOG	
			#ifdef V_CW_FOG
				#pragma multi_compile_fog
			#endif   

			#include "../cginc/CurvedWorld_Outline.cginc"
						      
			ENDCG  
		} //Pass
	} //SubShader

	Fallback Off
}
