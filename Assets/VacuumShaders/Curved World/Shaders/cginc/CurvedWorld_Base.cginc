#ifndef VACUUM_CURVEDWORLD_BASE_CGINC
#define VACUUM_CURVEDWORLD_BASE_CGINC 

#include "UnityCG.cginc"
 

/*DO NOT DELETE - CURVED WORLD BEND TYPE*/ #define BENDTYPE_CLASSIC_RUNNER_AXIS_Z_POSITIVE

////////////////////////////////////////////////////////////////////////////
//																		  //
//Variables 															  //
//																		  //
////////////////////////////////////////////////////////////////////////////
uniform float4 _V_CW_PivotPoint_Position;
uniform float4 _V_CW_PivotPoint_2_Position;

uniform float3 _V_CW_BendAxis;
uniform float3 _V_CW_BendOffset;	

uniform float2 _V_CW_Angle;
uniform float2 _V_CW_MinimalRadius;

uniform float _V_CW_Rolloff;
////////////////////////////////////////////////////////////////////////////
//																		  //
//Constants 															  //
//																		  //
////////////////////////////////////////////////////////////////////////////
static const float2 _zero2 = float2(0,0);
static const float3 _zero3 = float3(0,0,0);
static const float2 _one2 = float2(1,1);
static const float3 _one3 = float3(1,1,1);

////////////////////////////////////////////////////////////////////////////
//																		  //
//Defines    															  //
//																		  //
////////////////////////////////////////////////////////////////////////////
#define SIGN(a) (a.x < 0 ? -1.0f : 1.0f)
#define SIGN2(a) (float2(a.x < 0 ? -1.0f : 1.0f, a.y < 0 ? -1.0f : 1.0f))

#define PI     3.14159265359
#define PI_2   6.28318530717
#define PI_0_5 1.57079632679

#define PIVOT   _V_CW_PivotPoint_Position.xyz
#define PIVOT_2 _V_CW_PivotPoint_2_Position.xyz


////////////////////////////////////////////////////////////////////////////
//																		  //
//            															  //
//																		  //
////////////////////////////////////////////////////////////////////////////

inline float Smooth(float x)
{
	float t = cos(x * PI_0_5);

	return 1 - t * t;
}

inline float2 Smooth2(float2 x)
{
	float2 t = cos(x * PI_0_5);

	return _one2 - t * t;
}

inline float3 Smooth3(float3 x)
{
	float3 t = cos(x * PI_0_5);

	return _one3 - t * t;
}

////////////////////////////////////////////////////////////////////////////
//																		  //
//Spiral    															  //
//																		  //
////////////////////////////////////////////////////////////////////////////

inline void RotateVertex(inout float3 vertex, float3 pivot, float3 axis, float angle)
{
	//degree to rad / 2
	angle *= 0.00872664625;


	float sinA, cosA;
	sincos(angle, sinA, cosA);

	float3 q = axis * sinA;

	//vertex
	vertex -= pivot;
	vertex += 2.0 * cross(q, cross(q, vertex) + vertex * cosA);
	vertex += pivot;		
}

inline void RotateVertexAndNormal(inout float3 vertex, inout float3 normal, float3 pivot, float3 axis, float angle)
{
	//degree to rad / 2
	angle *= 0.00872664625;


	float sinA, cosA;
	sincos(angle, sinA, cosA);

	float4 q = float4(axis * sinA, cosA);


	//normal
	float3 normalPosition = vertex + normal;
	normalPosition -= pivot;
	normalPosition += 2.0 * cross(q.xyz, cross(q.xyz, normalPosition) + q.w * normalPosition);
	normalPosition += pivot;


	//vertex
	vertex -= pivot;
	vertex += 2.0 * cross(q.xyz, cross(q.xyz, vertex) + q.w * vertex);
	vertex += pivot;		


	//normal
	normal = normalize(normalPosition - vertex);
}


inline void Spiral_H_Rotate_X_Positive(inout float3 vertex, float3 pivot, float absoluteValue, float smoothValue, float l, float angle)
{
	if (absoluteValue < 1)
	{
		vertex.x = pivot.x;
		vertex.y += pivot.y * smoothValue;
	}
	else
	{
		vertex.xy += float2(l, pivot.y);
		// vertex.x += l;
		// vertex.y += pivot.y;
	}		

	RotateVertex(vertex, pivot, float3(0, 1, 0), angle * saturate(absoluteValue));
}

inline void Spiral_H_Rotate_X_Negative(inout float3 vertex, float3 pivot, float absoluteValue, float smoothValue, float l, float angle)
{
	if (absoluteValue < 1)
	{
		vertex.x = pivot.x;
		vertex.y += pivot.y * smoothValue;
	}
	else
	{
		vertex.xy += float2(-l, pivot.y);
		// vertex.x -= l;
		// vertex.y += pivot.y;
	}			

	RotateVertex(vertex, pivot, float3(0, -1, 0), angle * saturate(absoluteValue));
}

inline void Spiral_H_Rotate_Z_Positive(inout float3 vertex, float3 pivot, float absoluteValue, float smoothValue, float l, float angle)
{
	if (absoluteValue < 1)
	{
		vertex.z = pivot.z;
		vertex.y += pivot.y * smoothValue;
	}
	else
	{
		vertex.zy += float2(-l, pivot.y);
		// vertex.z -= l;
		// vertex.y += pivot.y;
	}				

	RotateVertex(vertex, pivot, float3(0, 1, 0), angle * saturate(absoluteValue));
}

inline void Spiral_H_Rotate_Z_Negative(inout float3 vertex, float3 pivot, float absoluteValue, float smoothValue, float l, float angle)
{
	if (absoluteValue < 1)
	{
		vertex.z = pivot.z;
		vertex.y += pivot.y * smoothValue;
	}
	else
	{
		vertex.zy += float2(l, pivot.y);
		// vertex.z += l;
		// vertex.y += pivot.y;
	}				

	RotateVertex(vertex, pivot, float3(0, -1, 0), angle * saturate(absoluteValue));
}


inline void Spiral_V_Rotate_X_Positive(inout float3 vertex, float3 pivot, float absoluteValue, float smoothValue, float l, float angle)
{
	if (absoluteValue < 1)
	{
		vertex.x = pivot.x;
		vertex.z += pivot.z * smoothValue;
	}
	else
	{
		vertex.xz += float2(l, pivot.z);
		// vertex.x += l;
		// vertex.z += pivot.z;
	}			

	RotateVertex(vertex, pivot, -float3(0, 0, 1), angle * saturate(absoluteValue));
}

inline void Spiral_V_Rotate_X_Negative(inout float3 vertex, float3 pivot, float absoluteValue, float smoothValue, float l, float angle)
{
	if (absoluteValue < 1)
	{
		vertex.x = pivot.x;
		vertex.z += pivot.z * smoothValue;
	}
	else
	{
		vertex.xz += float2(-l, pivot.z);
		// vertex.x -= l;
		// vertex.z += pivot.z;
	}			

	RotateVertex(vertex, pivot, float3(0, 0, 1), angle * saturate(absoluteValue));
}

inline void Spiral_V_Rotate_Z_Positive(inout float3 vertex, float3 pivot, float absoluteValue, float smoothValue, float l, float angle)
{
	if (absoluteValue < 1)
	{
		vertex.z = pivot.z;
		vertex.x += pivot.x * smoothValue;
	}
	else
	{
		vertex.zx += float2(-l, pivot.x);
		//vertex.z -= l;
  		//vertex.x += pivot.x;
	}			

	RotateVertex(vertex, pivot, -float3(1, 0, 0), angle * saturate(absoluteValue));
}

inline void Spiral_V_Rotate_Z_Negative(inout float3 vertex, float3 pivot, float absoluteValue, float smoothValue, float l, float angle)
{
	if (absoluteValue < 1)
	{
		 vertex.z = pivot.z;
		 vertex.x += pivot.x * smoothValue;
	}
	else
	{
		vertex.zx += float2(l, pivot.x);
		//vertex.z += l;
		//vertex.x += pivot.x;
	}			

	RotateVertex(vertex, pivot, float3(1, 0, 0), angle * saturate(absoluteValue));
}

////////////////////////////////////////////////////////////////////////////
//																		  //
//Vertex Transform														  //
//																		  //
////////////////////////////////////////////////////////////////////////////

inline void V_CW_TransformPoint(inout float4 vertex)
{	
	#if defined(BENDTYPE_CLASSIC_RUNNER_AXIS_X_POSITIVE)
		
		float4 worldPos = mul(unity_ObjectToWorld, vertex);
		worldPos.xyz -= PIVOT;

		float2 xyOff = max(_zero2, worldPos.xx - _V_CW_BendOffset.xy);
		xyOff *= xyOff;
		worldPos = float4(0.0f, _V_CW_BendAxis.x * xyOff.x, -_V_CW_BendAxis.y * xyOff.y, 0.0f) * 0.001;

		vertex += mul(unity_WorldToObject, worldPos);

	#elif defined(BENDTYPE_CLASSIC_RUNNER_AXIS_X_NEGATIVE)

		float4 worldPos = mul(unity_ObjectToWorld, vertex);
		worldPos.xyz -= PIVOT;

		float2 xyOff = min(_zero2, worldPos.xx + _V_CW_BendOffset.xy);
		xyOff *= xyOff;
		worldPos = float4(0.0f, _V_CW_BendAxis.x * xyOff.x, -_V_CW_BendAxis.y * xyOff.y, 0.0f) * 0.001;

		vertex += mul(unity_WorldToObject, worldPos);

	#elif defined(BENDTYPE_CLASSIC_RUNNER_AXIS_Z_NEGATIVE)

		float4 worldPos = mul(unity_ObjectToWorld, vertex);
		worldPos.xyz -= PIVOT;

		float2 xyOff = min(_zero2, worldPos.zz + _V_CW_BendOffset.xy);
		xyOff *= xyOff;
		worldPos = float4(-_V_CW_BendAxis.y * xyOff.y, _V_CW_BendAxis.x * xyOff.x, 0.0f, 0.0f) * 0.001;

		vertex += mul(unity_WorldToObject, worldPos);

	#elif defined(BENDTYPE_CLASSIC_RUNNER_AXIS_Z_POSITIVE)

		float4 worldPos = mul(unity_ObjectToWorld, vertex);
		worldPos.xyz -= PIVOT;

		float2 xyOff = max(_zero2, worldPos.zz - _V_CW_BendOffset.xy);
		xyOff *= xyOff;
		worldPos = float4(-_V_CW_BendAxis.y * xyOff.y, _V_CW_BendAxis.x * xyOff.x, 0.0f, 0.0f) * 0.001;

		vertex += mul(unity_WorldToObject, worldPos);

	#elif defined(BENDTYPE_LITTLE_PLANET) 
		
		float4 worldPos = mul( unity_ObjectToWorld, vertex ); 
		worldPos.xyz -= PIVOT;

		float2 xzOff = max(_zero2, abs(worldPos.zx) - _V_CW_BendOffset.xx);
		xzOff *= step(_zero2, worldPos.zx) * 2 - 1;
		xzOff *= xzOff;
		worldPos = float4(0, -(_V_CW_BendAxis.x * xzOff.x + _V_CW_BendAxis.x * xzOff.y) * 0.001, 0, 0); 

		vertex += mul(unity_WorldToObject, worldPos);


	#elif defined(BENDTYPE_CYLINDRICAL_TOWER_AXIS_X)

		float4 worldPos = mul(unity_ObjectToWorld, vertex);
		worldPos.xyz -= PIVOT;

		float2 xyOff = max(_zero2, abs(worldPos.xy) - _V_CW_BendOffset.yy);
		xyOff *= step(_zero2, worldPos.xy) * 2 - 1;
		xyOff *= xyOff;
		worldPos = float4(0, 0, _V_CW_BendAxis.y * xyOff.x, 0) * 0.001;

		vertex += mul(unity_WorldToObject, worldPos);

	#elif defined(BENDTYPE_CYLINDRICAL_TOWER_AXIS_Z)

		float4 worldPos = mul(unity_ObjectToWorld, vertex);
		worldPos.xyz -= PIVOT;

		float2 xyOff = max(_zero2, abs(worldPos.zy) - _V_CW_BendOffset.yy);
		xyOff *= step(_zero2, worldPos.zy) * 2 - 1;
		xyOff *= xyOff;
		worldPos = float4(_V_CW_BendAxis.y * xyOff.x, 0, 0, 0) * 0.001;

		vertex += mul(unity_WorldToObject, worldPos);

	#elif defined(BENDTYPE_CYLINDRICAL_ROLLOFF_AXIS_X) 

		float4 worldPos = mul(unity_ObjectToWorld, vertex);
		worldPos.xyz -= PIVOT;

		float2 xzOff = max(_zero2, abs(worldPos.zx) - _V_CW_BendOffset.xx);
		xzOff *= step(_zero2, worldPos.zx) * 2 - 1;
		xzOff *= xzOff;
		worldPos = float4(0, -(_V_CW_BendAxis.x * xzOff.y) * 0.001, 0, 0);

		vertex += mul(unity_WorldToObject, worldPos);

	#elif defined(BENDTYPE_CYLINDRICAL_ROLLOFF_AXIS_Z) 

		float4 worldPos = mul(unity_ObjectToWorld, vertex);
		worldPos.xyz -= PIVOT;

		float2 xzOff = max(_zero2, abs(worldPos.zx) - _V_CW_BendOffset.xx);
		xzOff *= step(_zero2, worldPos.zx) * 2 - 1;
		xzOff *= xzOff;
		worldPos = float4(0, -(_V_CW_BendAxis.x * xzOff.x) * 0.001, 0, 0);

		vertex += mul(unity_WorldToObject, worldPos);

	#elif defined(BENDTYPE_UNIVERSAL)
		
		float4 worldPos = mul( unity_ObjectToWorld, vertex ); 
		worldPos.xyz -= PIVOT;

		float3 xyzOff = max(_zero3, abs(worldPos.zzx) - _V_CW_BendOffset.xyz);
		xyzOff *= step(_zero3, worldPos.zzx) * 2 - 1;
		xyzOff *= xyzOff;
		worldPos = float4(-_V_CW_BendAxis.y * xyzOff.y, _V_CW_BendAxis.x * xyzOff.x + _V_CW_BendAxis.z * xyzOff.z, 0.0f, 0.0f) * 0.001; 

		vertex += mul(unity_WorldToObject, worldPos);


	#elif defined(BENDTYPE_PERSPECTIVE_2D)

		float4 modelView = float4(UnityObjectToViewPos(vertex).xyz, 1);

		float2 xyOff = max(_zero2, abs(modelView.yx) - _V_CW_BendOffset.xy) * SIGN(modelView.yx);	
		xyOff *= xyOff;
		modelView.z -= (_V_CW_BendAxis.x * xyOff.x + _V_CW_BendAxis.y * xyOff.y) * 0.001;
			
		vertex = mul(modelView, UNITY_MATRIX_IT_MV);

	#elif defined(BENDTYPE_SPIRAL_HORIZONTAL_AXIS_X_POSITIVE)

		float3 worldPos = mul(unity_ObjectToWorld, vertex);

		if(worldPos.x > PIVOT.x)
		{
			PIVOT.z = abs(PIVOT.z) < _V_CW_MinimalRadius.x ? _V_CW_MinimalRadius.x * SIGN(PIVOT.z) : PIVOT.z;
			float radius = PIVOT.z;

			float angle = _V_CW_Angle.x * SIGN(radius);
			float l = PI_2 * radius * (angle / 360);

			float absX = abs(PIVOT.x - worldPos.x) / l;
			float smoothAbsX = Smooth(absX);


			Spiral_H_Rotate_X_Negative(worldPos, PIVOT, absX, smoothAbsX, l, angle);
		}

		vertex = mul(unity_WorldToObject, float4(worldPos, 1));		

	#elif defined(BENDTYPE_SPIRAL_HORIZONTAL_AXIS_X_NEGATIVE)

		 float3 worldPos = mul(unity_ObjectToWorld, vertex);

		if(worldPos.x < PIVOT.x)
		{
			PIVOT.z = abs(PIVOT.z) < _V_CW_MinimalRadius.x ? _V_CW_MinimalRadius.x * SIGN(PIVOT.z) : PIVOT.z;
			float radius = PIVOT.z;

			float angle = _V_CW_Angle.x * SIGN(radius);
			float l = PI_2 * radius * (angle / 360);

			float absX = abs(PIVOT.x - worldPos.x) / l;
			float smoothAbsX = Smooth(absX);


			Spiral_H_Rotate_X_Positive(worldPos, PIVOT, absX, smoothAbsX, l, angle);
		}

		vertex = mul(unity_WorldToObject, float4(worldPos, 1));	

	#elif defined(BENDTYPE_SPIRAL_HORIZONTAL_AXIS_Z_NEGATIVE)

		float3 worldPos = mul(unity_ObjectToWorld, vertex);

		if(worldPos.z < PIVOT.z)
		{
			PIVOT.x = abs(PIVOT.x) < _V_CW_MinimalRadius.x ? _V_CW_MinimalRadius.x * SIGN(PIVOT.x) : PIVOT.x;
			float radius = PIVOT.x;

			float angle = _V_CW_Angle.x * SIGN(radius);
			float l = PI_2 * radius * (angle / 360);

			float absZ = abs(PIVOT.z - worldPos.z) / l;
			float smoothAbsZ = Smooth(absZ);


			Spiral_H_Rotate_Z_Negative(worldPos, PIVOT, absZ, smoothAbsZ, l, angle);
		}

		vertex = mul(unity_WorldToObject, float4(worldPos, 1));

	#elif defined(BENDTYPE_SPIRAL_HORIZONTAL_AXIS_Z_POSITIVE)

		float3 worldPos = mul(unity_ObjectToWorld, vertex);

		if(worldPos.z > PIVOT.z)
		{
			PIVOT.x = abs(PIVOT.x) < _V_CW_MinimalRadius.x ? _V_CW_MinimalRadius.x * SIGN(PIVOT.x) : PIVOT.x;
			float radius = PIVOT.x;

			float angle = _V_CW_Angle.x * SIGN(radius);
			float l = PI_2 * radius * (angle / 360);

			float absZ = abs(PIVOT.z - worldPos.z) / l;
			float smoothAbsZ = Smooth(absZ);


			Spiral_H_Rotate_Z_Positive(worldPos, PIVOT, absZ, smoothAbsZ, l, angle);
		}

		vertex = mul(unity_WorldToObject, float4(worldPos, 1));

	#elif defined(BENDTYPE_SPIRAL_HORIZONTAL_DOUBLE_AXIS_X)

		float3 worldPos = mul(unity_ObjectToWorld, vertex);

		float2 p = float2(PIVOT.z, PIVOT_2.z);
		float2 radius = abs(p) < _V_CW_MinimalRadius ? _V_CW_MinimalRadius * SIGN2(p) : p;
				

		float2 angle = _V_CW_Angle * SIGN2(radius);
		float2 l = PI_2 * radius * (angle / 360);

		float2 absX = abs(float2(PIVOT.x, PIVOT_2.x) - worldPos.xx) / l;
		float2 smoothAbsX = Smooth2(absX);


		if(worldPos.x < PIVOT.x)
		{
			PIVOT.z = radius.x;
			Spiral_H_Rotate_X_Positive(worldPos, PIVOT, absX.x, smoothAbsX.x, l.x, angle.x);
		}
		else if(worldPos.x.x > PIVOT_2.x)
		{
			PIVOT_2.z = radius.y;
			Spiral_H_Rotate_X_Negative(worldPos, PIVOT_2, absX.y, smoothAbsX.y, l.y, angle.y);
		}

		vertex = mul(unity_WorldToObject, float4(worldPos, 1));		 

	#elif defined(BENDTYPE_SPIRAL_HORIZONTAL_DOUBLE_AXIS_Z)

		float3 worldPos = mul(unity_ObjectToWorld, vertex);

		float2 p = float2(PIVOT.x, PIVOT_2.x);
		float2 radius = abs(p) < _V_CW_MinimalRadius ? _V_CW_MinimalRadius * SIGN2(p) : p;

		float2 angle = _V_CW_Angle * SIGN2(radius);
		float2 l = PI_2 * radius * (angle / 360);

		float2 absZ = abs(float2(PIVOT.z, PIVOT_2.z) - worldPos.zz) / l;
		float2 smoothAbsZ = Smooth2(absZ);


		if(worldPos.z < PIVOT.z)
		{
			PIVOT.x = radius.x;
			Spiral_H_Rotate_Z_Negative(worldPos, PIVOT, absZ.x, smoothAbsZ.x, l.x, angle.x);
		}
		else if(worldPos.z > PIVOT_2.z)
		{			
			PIVOT_2.x = radius.y;
			Spiral_H_Rotate_Z_Positive(worldPos, PIVOT_2, absZ.y, smoothAbsZ.y, l.y, angle.y);
		}

		vertex = mul(unity_WorldToObject, float4(worldPos, 1));

	#elif defined(BENDTYPE_SPIRAL_HORIZONTAL_ROLLOFF_AXIS_X)

		PIVOT_2.x = PIVOT.x + _V_CW_Rolloff;	
		PIVOT_2.zy = PIVOT.zy;

		PIVOT.x -= _V_CW_Rolloff;


		float3 worldPos = mul(unity_ObjectToWorld, vertex);

		float radius = abs(PIVOT.z) < _V_CW_MinimalRadius.x ? _V_CW_MinimalRadius.x * SIGN(PIVOT.z) : PIVOT.z;	
		float angle = _V_CW_Angle.x * SIGN(radius);
		float l = PI_2 * radius * (angle / 360);

		float2 absX = abs(float2(PIVOT.x, PIVOT_2.x) - worldPos.xx) / l;
		float2 smoothAbsX = Smooth2(absX);


		if(worldPos.x < PIVOT.x)
		{
			PIVOT.z = radius;
			Spiral_H_Rotate_X_Positive(worldPos, PIVOT, absX.x, smoothAbsX.x, l, angle);
		}
		else if(worldPos.x.x > PIVOT_2.x)
		{
			PIVOT_2.z = radius;
			Spiral_H_Rotate_X_Negative(worldPos, PIVOT_2, absX.y, smoothAbsX.y, l, angle);
		}

		vertex = mul(unity_WorldToObject, float4(worldPos, 1));		 

	#elif defined(BENDTYPE_SPIRAL_HORIZONTAL_ROLLOFF_AXIS_Z)

		PIVOT_2.z = PIVOT.z + _V_CW_Rolloff;	
		PIVOT_2.xy = PIVOT.xy;

		PIVOT.z -= _V_CW_Rolloff;


		float3 worldPos = mul(unity_ObjectToWorld, vertex);

		float radius = abs(PIVOT.x) < _V_CW_MinimalRadius.x ? _V_CW_MinimalRadius.x * SIGN(PIVOT.x) : PIVOT.x;

		float angle = _V_CW_Angle.x * SIGN(radius);
		float l = PI_2 * radius * (angle / 360);

		float2 absZ = abs(float2(PIVOT.z, PIVOT_2.z) - worldPos.zz) / l;
		float2 smoothAbsZ = Smooth2(absZ);


		if(worldPos.z < PIVOT.z)
		{
			PIVOT.x = radius;
			Spiral_H_Rotate_Z_Negative(worldPos, PIVOT, absZ.x, smoothAbsZ.x, l, angle);
		}
		else if(worldPos.z > PIVOT_2.z)
		{			
			PIVOT_2.x = radius;
			Spiral_H_Rotate_Z_Positive(worldPos, PIVOT_2, absZ.y, smoothAbsZ.y, l, angle);
		}

		vertex = mul(unity_WorldToObject, float4(worldPos, 1));

	#elif defined(BENDTYPE_SPIRAL_VERTICAL_AXIS_X_POSITIVE)

		float3 worldPos = mul(unity_ObjectToWorld, vertex);

		if(worldPos.x > PIVOT.x)
		{
			PIVOT.y = abs(PIVOT.y) < _V_CW_MinimalRadius.x ? _V_CW_MinimalRadius.x * SIGN(PIVOT.y) : PIVOT.y;
			float radius = PIVOT.y;

			float angle = _V_CW_Angle.x * SIGN(radius);
			float l = PI_2 * radius * (angle / 360);

			float absX = abs(PIVOT.x - worldPos.x) / l;
			float smoothAbsX = Smooth(absX);
				

			Spiral_V_Rotate_X_Negative(worldPos, PIVOT, absX, smoothAbsX, l, angle);
		}

		vertex = mul(unity_WorldToObject, float4(worldPos, 1));	

	#elif defined(BENDTYPE_SPIRAL_VERTICAL_AXIS_X_NEGATIVE)

		float3 worldPos = mul(unity_ObjectToWorld, vertex);
			
		if(worldPos.x < PIVOT.x)
		{
			PIVOT.y = abs(PIVOT.y) < _V_CW_MinimalRadius.x ? _V_CW_MinimalRadius.x * SIGN(PIVOT.y) : PIVOT.y;
			float radius = PIVOT.y;

			float angle = _V_CW_Angle.x * SIGN(radius);
			float l = PI_2 * radius * (angle / 360);

			float absX = abs(PIVOT.x - worldPos.x) / l;
			float smoothAbsX = Smooth(absX);


			Spiral_V_Rotate_X_Positive(worldPos, PIVOT, absX, smoothAbsX, l, angle);
		}

		vertex = mul(unity_WorldToObject, float4(worldPos, 1));	

	#elif defined(BENDTYPE_SPIRAL_VERTICAL_AXIS_Z_NEGATIVE)

		float3 worldPos = mul(unity_ObjectToWorld, vertex);

		if(worldPos.z < PIVOT.z)
		{
			PIVOT.y = abs(PIVOT.y) < _V_CW_MinimalRadius.x ? _V_CW_MinimalRadius.x * SIGN(PIVOT.y) : PIVOT.y;
			float radius = PIVOT.y;

			float angle = _V_CW_Angle.x * SIGN(radius);
			float l = PI_2 * radius * (angle / 360);

			float absZ = abs(PIVOT.z - worldPos.z) / l;
			float smoothAbsZ = Smooth(absZ);


			Spiral_V_Rotate_Z_Negative(worldPos, PIVOT, absZ, smoothAbsZ, l, angle);
		}

		vertex = mul(unity_WorldToObject, float4(worldPos, 1));	

	#elif defined(BENDTYPE_SPIRAL_VERTICAL_AXIS_Z_POSITIVE)
			
		float3 worldPos = mul(unity_ObjectToWorld, vertex);

		if(worldPos.z > PIVOT.z)
		{
			PIVOT.y = abs(PIVOT.y) < _V_CW_MinimalRadius.x ? _V_CW_MinimalRadius.x * SIGN(PIVOT.y) : PIVOT.y;
			float radius = PIVOT.y;

			float angle = _V_CW_Angle.x * SIGN(radius);
			float l = PI_2 * radius * (angle / 360);

			float absZ = abs(PIVOT.z - worldPos.z) / l;
			float smoothAbsZ = Smooth(absZ);


			Spiral_V_Rotate_Z_Positive(worldPos, PIVOT, absZ, smoothAbsZ, l, angle);
		}

		vertex = mul(unity_WorldToObject, float4(worldPos, 1));	

	#elif defined(BENDTYPE_SPIRAL_VERTICAL_DOUBLE_AXIS_X)

		float3 worldPos = mul(unity_ObjectToWorld, vertex);
			
		float2 p = float2(PIVOT.y, PIVOT_2.y);
		float2 radius = abs(p) < _V_CW_MinimalRadius ? _V_CW_MinimalRadius * SIGN2(p) : p;
		float2 angle = _V_CW_Angle * SIGN2(radius);
		float2 l = PI_2 * radius * (angle / 360);
		float2 absX = abs(float2(PIVOT.x, PIVOT_2.x) - worldPos.xx) / l;
		float2 smoothAbsX = Smooth2(absX);

		if(worldPos.x < PIVOT.x)
		{
			PIVOT.y = radius.x;

			Spiral_V_Rotate_X_Positive(worldPos, PIVOT, absX.x, smoothAbsX.x, l.x, angle.x);
		}
		else if(worldPos.x > PIVOT_2.x)
		{
			PIVOT_2.y = radius.y;								

			Spiral_V_Rotate_X_Negative(worldPos, PIVOT_2, absX.y, smoothAbsX.y, l.y, angle.y);
		}


		vertex = mul(unity_WorldToObject, float4(worldPos, 1));	

	#elif defined(BENDTYPE_SPIRAL_VERTICAL_DOUBLE_AXIS_Z)

		float3 worldPos = mul(unity_ObjectToWorld, vertex);

		float2 p = float2(PIVOT.y, PIVOT_2.y);
		float2 radius = abs(p) < _V_CW_MinimalRadius ? _V_CW_MinimalRadius * SIGN2(p) : p;
		float2 angle = _V_CW_Angle * SIGN2(radius);
		float2 l = PI_2 * radius * (angle / 360);
		float2 absZ = abs(float2(PIVOT.z, PIVOT_2.z) - worldPos.zz) / l;
		float2 smoothAbsZ = Smooth2(absZ);

		if(worldPos.z < PIVOT.z)
		{
			PIVOT.y = radius.x;

			Spiral_V_Rotate_Z_Negative(worldPos, PIVOT, absZ.x, smoothAbsZ.x, l.x, angle.x);
		}
		else if(worldPos.z > PIVOT_2.z)
		{
			PIVOT_2.y = radius.y;

			Spiral_V_Rotate_Z_Positive(worldPos, PIVOT_2, absZ.y, smoothAbsZ.y, l.y, angle.y);
		}

		vertex = mul(unity_WorldToObject, float4(worldPos, 1));	

	#elif defined(BENDTYPE_SPIRAL_VERTICAL_ROLLOFF_AXIS_X)

		PIVOT_2.x = PIVOT.x + _V_CW_Rolloff;	
		PIVOT_2.yz = PIVOT.yz;

		PIVOT.x -= _V_CW_Rolloff;


		float3 worldPos = mul(unity_ObjectToWorld, vertex);
			
		float radius = abs(PIVOT.y) < _V_CW_MinimalRadius.x ? _V_CW_MinimalRadius.x * SIGN(PIVOT.y) : PIVOT.y;
		float angle = _V_CW_Angle.x * SIGN(radius);
		float l = PI_2 * radius * (angle / 360);
		float2 absX = abs(float2(PIVOT.x, PIVOT_2.x) - worldPos.xx) / l;
		float2 smoothAbsX = Smooth2(absX);

		if(worldPos.x < PIVOT.x)
		{
			PIVOT.y = radius;

			Spiral_V_Rotate_X_Positive(worldPos, PIVOT, absX.x, smoothAbsX.x, l, angle);
		}
		else if(worldPos.x > PIVOT_2.x)
		{
			PIVOT_2.y = radius;								

			Spiral_V_Rotate_X_Negative(worldPos, PIVOT_2, absX.y, smoothAbsX.y, l, angle);
		}


		vertex = mul(unity_WorldToObject, float4(worldPos, 1));	

	#elif defined(BENDTYPE_SPIRAL_VERTICAL_ROLLOFF_AXIS_Z)

		PIVOT_2.z = PIVOT.z + _V_CW_Rolloff;	
		PIVOT_2.xy = PIVOT.xy;

		PIVOT.z -= _V_CW_Rolloff;


		float3 worldPos = mul(unity_ObjectToWorld, vertex);

		float radius = abs(PIVOT.y) < _V_CW_MinimalRadius.x ? _V_CW_MinimalRadius.x * SIGN(PIVOT.y) : PIVOT.y;
		float angle = _V_CW_Angle.x * SIGN(radius);
		float l = PI_2 * radius * (angle / 360);
		float2 absZ = abs(float2(PIVOT.z, PIVOT_2.z) - worldPos.zz) / l;
		float2 smoothAbsZ = Smooth2(absZ);

		if(worldPos.z < PIVOT.z)
		{
			PIVOT.y = radius;

			Spiral_V_Rotate_Z_Negative(worldPos, PIVOT, absZ.x, smoothAbsZ.x, l, angle);
		}
		else if(worldPos.z > PIVOT_2.z)
		{
			PIVOT_2.y = radius;

			Spiral_V_Rotate_Z_Positive(worldPos, PIVOT_2, absZ.y, smoothAbsZ.y, l, angle);
		}

		vertex = mul(unity_WorldToObject, float4(worldPos, 1));	

	#else
		
		//Do nothing

	#endif
} 

inline void V_CW_TransformPointAndNormal(inout float4 vertex, inout float3 normal, float3 worldPos, float3 worldTangent, float3 worldBinormal)
{

	float3 v0 = worldPos;
	#if defined(BENDTYPE_CLASSIC_RUNNER_AXIS_X_POSITIVE) || defined(BENDTYPE_CLASSIC_RUNNER_AXIS_X_NEGATIVE) || defined(BENDTYPE_CLASSIC_RUNNER_AXIS_Z_POSITIVE) || defined(BENDTYPE_CLASSIC_RUNNER_AXIS_Z_NEGATIVE)
		v0 -= PIVOT;	
	#endif
	#if defined(BENDTYPE_LITTLE_PLANET) || defined(BENDTYPE_UNIVERSAL) || defined(BENDTYPE_PERSPECTIVE2D)		
		v0 -= PIVOT;	
	#endif
	#if  defined(BENDTYPE_CYLINDRICAL_ROLLOFF_AXIS_X) || defined(BENDTYPE_CYLINDRICAL_ROLLOFF_AXIS_Z) || defined(BENDTYPE_CYLINDRICAL_TOWER_AXIS_X) || defined(BENDTYPE_CYLINDRICAL_TOWER_AXIS_Z)
		v0 -= PIVOT;	
	#endif

	float3 v1 = v0 + worldTangent;
	float3 v2 = v0 + worldBinormal;
	

	#if defined(BENDTYPE_CLASSIC_RUNNER_AXIS_X_POSITIVE)

		float2 xyOff = max(_zero2, v0.xx - _V_CW_BendOffset.xy);
		xyOff *= xyOff;
		float3 transformedVertex = float3(0.0f, _V_CW_BendAxis.x * xyOff.x, -_V_CW_BendAxis.y * xyOff.y) * 0.001;
		v0 += transformedVertex;			


		xyOff = max(_zero2, v1.xx - _V_CW_BendOffset.xy);
		xyOff *= xyOff;
		v1 += float3(0.0f, _V_CW_BendAxis.x * xyOff.x, -_V_CW_BendAxis.y * xyOff.y) * 0.001;
			

		xyOff = max(_zero2, v2.xx - _V_CW_BendOffset.xy);
		xyOff *= xyOff;
		v2 += float3(0.0f, _V_CW_BendAxis.x * xyOff.x, -_V_CW_BendAxis.y * xyOff.y) * 0.001;


		vertex.xyz += mul((float3x3)unity_WorldToObject, transformedVertex);
		normal = normalize(mul((float3x3)unity_WorldToObject, normalize(cross(v2 - v0, v1 - v0))));

	#elif defined(BENDTYPE_CLASSIC_RUNNER_AXIS_X_NEGATIVE)

		float2 xyOff = min(_zero2, v0.xx + _V_CW_BendOffset.xy);
		xyOff *= xyOff;
		float3 transformedVertex = float3(0.0f, _V_CW_BendAxis.x * xyOff.x, -_V_CW_BendAxis.y * xyOff.y) * 0.001;
		v0 += transformedVertex;
			

		xyOff = min(_zero2, v1.xx + _V_CW_BendOffset.xy);
		xyOff *= xyOff;
		v1 += float3(0.0f, _V_CW_BendAxis.x * xyOff.x, -_V_CW_BendAxis.y * xyOff.y) * 0.001;

			
		xyOff = min(_zero2, v2.xx + _V_CW_BendOffset.xy);
		xyOff *= xyOff;
		v2 += float3(0.0f, _V_CW_BendAxis.x * xyOff.x, -_V_CW_BendAxis.y * xyOff.y) * 0.001;


		vertex.xyz += mul((float3x3)unity_WorldToObject, transformedVertex);
		normal = normalize(mul((float3x3)unity_WorldToObject, normalize(cross(v2 - v0, v1 - v0))));

	#elif defined(BENDTYPE_CLASSIC_RUNNER_AXIS_Z_NEGATIVE)

		float2 xyOff = min(_zero2, v0.zz + _V_CW_BendOffset.xy);
		xyOff *= xyOff;
		float3 transformedVertex = float3(-_V_CW_BendAxis.y * xyOff.y, _V_CW_BendAxis.x * xyOff.x, 0.0f) * 0.001;
		v0 += transformedVertex;
			

		xyOff = min(_zero2, v1.zz + _V_CW_BendOffset.xy);
		xyOff *= xyOff;
		v1 += float3(-_V_CW_BendAxis.y * xyOff.y, _V_CW_BendAxis.x * xyOff.x, 0.0f) * 0.001; 

			
		xyOff = min(_zero2, v2.zz + _V_CW_BendOffset.xy);
		xyOff *= xyOff;
		v2 += float3(-_V_CW_BendAxis.y * xyOff.y, _V_CW_BendAxis.x * xyOff.x, 0.0f) * 0.001; 


		vertex.xyz += mul((float3x3)unity_WorldToObject, transformedVertex);
		normal = normalize(mul((float3x3)unity_WorldToObject, normalize(cross(v2 - v0, v1 - v0))));

	#elif defined(BENDTYPE_CLASSIC_RUNNER_AXIS_Z_POSITIVE)

		float2 xyOff = max(_zero2, v0.zz - _V_CW_BendOffset.xy);
		xyOff *= xyOff;
		float3 transformedVertex = float3(-_V_CW_BendAxis.y * xyOff.y, _V_CW_BendAxis.x * xyOff.x, 0.0f) * 0.001;
		v0 += transformedVertex;
			

		xyOff = max(_zero2, v1.zz - _V_CW_BendOffset.xy);
		xyOff *= xyOff;
		v1 += float3(-_V_CW_BendAxis.y * xyOff.y, _V_CW_BendAxis.x * xyOff.x, 0.0f) * 0.001; 

			
		xyOff = max(_zero2, v2.zz - _V_CW_BendOffset.xy);
		xyOff *= xyOff;
		v2 += float3(-_V_CW_BendAxis.y * xyOff.y, _V_CW_BendAxis.x * xyOff.x, 0.0f) * 0.001; 


		vertex.xyz += mul((float3x3)unity_WorldToObject, transformedVertex);
		normal = normalize(mul((float3x3)unity_WorldToObject, normalize(cross(v2 - v0, v1 - v0))));

	#elif defined(BENDTYPE_LITTLE_PLANET)

		float2 xzOff = max(_zero2, abs(v0.zx) - _V_CW_BendOffset.xx);
		xzOff *= step(_zero2, v0.zx) * 2 - 1;
		xzOff *= xzOff;
		float3 transformedVertex = float3(0, -(_V_CW_BendAxis.x * xzOff.x + _V_CW_BendAxis.x * xzOff.y) * 0.001, 0); 
		v0 += transformedVertex;
					  
	  		
		xzOff = max(_zero2, abs(v1.zx) - _V_CW_BendOffset.xx);
		xzOff *= step(_zero2, v1.zx) * 2 - 1;
		xzOff *= xzOff; 		
		v1.y += -(_V_CW_BendAxis.x * xzOff.x + _V_CW_BendAxis.x * xzOff.y) * 0.001;
				 
			
		xzOff = max(_zero2, abs(v2.zx) - _V_CW_BendOffset.xx);
		xzOff *= step(_zero2, v2.zx) * 2 - 1;
		xzOff *= xzOff; 		
		v2.y += -(_V_CW_BendAxis.x * xzOff.x + _V_CW_BendAxis.x * xzOff.y) * 0.001;	


		vertex.xyz += mul((float3x3)unity_WorldToObject, transformedVertex);
		normal = normalize(mul((float3x3)unity_WorldToObject, normalize(cross(v2 - v0, v1 - v0))));

	#elif defined(BENDTYPE_UNIVERSAL)

		float3 xyzOff = max(_zero3, abs(v0.zx).xxy - _V_CW_BendOffset);
		xyzOff *= step(_zero3, v0.xxy) * 2 - 1;
		xyzOff *= xyzOff;
		float3 transformedVertex = float3(-_V_CW_BendAxis.y * xyzOff.y, _V_CW_BendAxis.x * xyzOff.x + _V_CW_BendAxis.z * xyzOff.z, 0.0f) * 0.001; 
		v0 += transformedVertex;
		

		xyzOff = max(_zero3, abs(v1.zx).xxy - _V_CW_BendOffset);
		xyzOff *= step(_zero3, v1.xxy) * 2 - 1;
		xyzOff *= xyzOff;
		v1.xy += float2(-_V_CW_BendAxis.y * xyzOff.y, _V_CW_BendAxis.x * xyzOff.x + _V_CW_BendAxis.z * xyzOff.z) * 0.001; 


		xyzOff = max(_zero3, abs(v2.zx).xxy - _V_CW_BendOffset);
		xyzOff *= step(_zero3, v2.xxy) * 2 - 1;
		xyzOff *= xyzOff;
		v2.xy += float2(-_V_CW_BendAxis.y * xyzOff.y, _V_CW_BendAxis.x * xyzOff.x + _V_CW_BendAxis.z * xyzOff.z) * 0.001; 
	
		
		vertex.xyz += mul((float3x3)unity_WorldToObject, transformedVertex);
		normal = normalize(mul((float3x3)unity_WorldToObject, normalize(cross(v2 - v0, v1 - v0))));

	#elif defined(BENDTYPE_CYLINDRICAL_TOWER_AXIS_X)

		float2 xyOff = max(_zero2, abs(v0.xy) - _V_CW_BendOffset.yy);
		xyOff *= step(_zero2, v0.xy) * 2 - 1;
		xyOff *= xyOff;
		float3 transformedVertex = float3(0, 0, _V_CW_BendAxis.y * xyOff.x * 0.001); 
		v0 += transformedVertex;
						
				
		xyOff = max(_zero2, abs(v1.xy) - _V_CW_BendOffset.yy);
		xyOff *= step(_zero2, v1.xy) * 2 - 1;
		xyOff *= xyOff; 		
		v1.z += _V_CW_BendAxis.y * xyOff.x * 0.001;
					
				
		xyOff = max(_zero2, abs(v2.xy) - _V_CW_BendOffset.yy);
		xyOff *= step(_zero2, v2.xy) * 2 - 1;
		xyOff *= xyOff; 		
		v2.z += _V_CW_BendAxis.y * xyOff.x * 0.001;	

		
		vertex.xyz += mul((float3x3)unity_WorldToObject, transformedVertex);
		normal = normalize(mul((float3x3)unity_WorldToObject, normalize(cross(v2 - v0, v1 - v0))));

	#elif defined(BENDTYPE_CYLINDRICAL_TOWER_AXIS_Z)

		float2 xyOff = max(_zero2, abs(v0.zy) - _V_CW_BendOffset.yy);
		xyOff *= step(_zero2, v0.zy) * 2 - 1;
		xyOff *= xyOff;
		float3 transformedVertex = float3(_V_CW_BendAxis.y * xyOff.x * 0.001, 0, 0); 
		v0 += transformedVertex;
						
				
		xyOff = max(_zero2, abs(v1.zy) - _V_CW_BendOffset.yy);
		xyOff *= step(_zero2, v1.zy) * 2 - 1;
		xyOff *= xyOff; 		
		v1.x += _V_CW_BendAxis.y * xyOff.x * 0.001;
					
				
		xyOff = max(_zero2, abs(v2.zy) - _V_CW_BendOffset.yy);
		xyOff *= step(_zero2, v2.zy) * 2 - 1;
		xyOff *= xyOff; 		
		v2.x += _V_CW_BendAxis.y * xyOff.x * 0.001;	

		
		vertex.xyz += mul((float3x3)unity_WorldToObject, transformedVertex);
		normal = normalize(mul((float3x3)unity_WorldToObject, normalize(cross(v2 - v0, v1 - v0))));

	#elif defined(BENDTYPE_CYLINDRICAL_ROLLOFF_AXIS_X) 

		float2 xzOff = max(_zero2, abs(v0.zx) - _V_CW_BendOffset.xx);
		xzOff *= step(_zero2, v0.zx) * 2 - 1;
		xzOff *= xzOff;
		float3 transformedVertex = float3(0, -(_V_CW_BendAxis.x * xzOff.y) * 0.001, 0.0f); 
		v0 += transformedVertex;
						
				
		xzOff = max(_zero2, abs(v1.zx) - _V_CW_BendOffset.xx);
		xzOff *= step(_zero2, v1.zx) * 2 - 1;
		xzOff *= xzOff; 		
		v1.y += -(_V_CW_BendAxis.x * xzOff.y) * 0.001;
					
				
		xzOff = max(_zero2, abs(v2.zx) - _V_CW_BendOffset.xx);
		xzOff *= step(_zero2, v2.zx) * 2 - 1;
		xzOff *= xzOff; 		
		v2.y += -(_V_CW_BendAxis.x * xzOff.y) * 0.001;	

			
		vertex.xyz += mul((float3x3)unity_WorldToObject, transformedVertex);
		normal = normalize(mul((float3x3)unity_WorldToObject, normalize(cross(v2 - v0, v1 - v0))));

	#elif defined(BENDTYPE_CYLINDRICAL_ROLLOFF_AXIS_Z) 

		float2 xzOff = max(_zero2, abs(v0.zx) - _V_CW_BendOffset.xx);
		xzOff *= step(_zero2, v0.zx) * 2 - 1;
		xzOff *= xzOff;
		float3 transformedVertex = float3(0, -(_V_CW_BendAxis.x * xzOff.x) * 0.001, 0.0f); 
		v0 += transformedVertex;
						
				
		xzOff = max(_zero2, abs(v1.zx) - _V_CW_BendOffset.xx);
		xzOff *= step(_zero2, v1.zx) * 2 - 1;
		xzOff *= xzOff; 		
		v1.y += -(_V_CW_BendAxis.x * xzOff.x) * 0.001;
					
				
		xzOff = max(_zero2, abs(v2.zx) - _V_CW_BendOffset.xx);
		xzOff *= step(_zero2, v2.zx) * 2 - 1;
		xzOff *= xzOff; 		
		v2.y += -(_V_CW_BendAxis.x * xzOff.x) * 0.001;	

			
		vertex.xyz += mul((float3x3)unity_WorldToObject, transformedVertex);
		normal = normalize(mul((float3x3)unity_WorldToObject, normalize(cross(v2 - v0, v1 - v0))));

	#elif defined(BENDTYPE_SPIRAL_HORIZONTAL_AXIS_X_POSITIVE)

		PIVOT.z = abs(PIVOT.z) < _V_CW_MinimalRadius.x ? _V_CW_MinimalRadius.x * SIGN(PIVOT.z) : PIVOT.z;
		float radius = PIVOT.z;

		float angle = _V_CW_Angle.x * SIGN(radius);
		float l = PI_2 * radius * (angle / 360);

		float3 absX = abs(PIVOT.xxx - float3(v0.x, v1.x, v2.x)) / l;
		float3 smoothAbsX = Smooth3(absX);


		if(v0.x > PIVOT.x)
		{
			Spiral_H_Rotate_X_Negative(v0, PIVOT, absX.x, smoothAbsX.x, l, angle);
		}
		if(v1.x > PIVOT.x)
		{
			Spiral_H_Rotate_X_Negative(v1, PIVOT, absX.y, smoothAbsX.y, l, angle);
		}
		if(v2.x > PIVOT.x)
		{
			Spiral_H_Rotate_X_Negative(v2, PIVOT, absX.z, smoothAbsX.z, l, angle);
		}

		vertex = mul(unity_WorldToObject, float4(v0, 1));
		normal = normalize(mul((float3x3)unity_WorldToObject, normalize(cross(v2 - v0, v1 - v0))));

	#elif defined(BENDTYPE_SPIRAL_HORIZONTAL_AXIS_X_NEGATIVE)

		PIVOT.z = abs(PIVOT.z) < _V_CW_MinimalRadius.x ? _V_CW_MinimalRadius.x * SIGN(PIVOT.z) : PIVOT.z;
		float radius = PIVOT.z;

		float angle = _V_CW_Angle.x * SIGN(radius);
		float l = PI_2 * radius * (angle / 360);

		float3 absX = abs(PIVOT.xxx - float3(v0.x, v1.x, v2.x)) / l;
		float3 smoothAbsX = Smooth3(absX);

		if(v0.x < PIVOT.x)
		{
			Spiral_H_Rotate_X_Positive(v0, PIVOT, absX.x, smoothAbsX.x, l, angle);
		}
		if(v1.x < PIVOT.x)
		{
			Spiral_H_Rotate_X_Positive(v1, PIVOT, absX.y, smoothAbsX.y, l, angle);
		}
		if(v2.x < PIVOT.x)
		{
			Spiral_H_Rotate_X_Positive(v2, PIVOT, absX.z, smoothAbsX.z, l, angle);
		}

		vertex = mul(unity_WorldToObject, float4(v0, 1));
		normal = normalize(mul((float3x3)unity_WorldToObject, normalize(cross(v2 - v0, v1 - v0))));

	#elif defined(BENDTYPE_SPIRAL_HORIZONTAL_AXIS_Z_NEGATIVE)

		PIVOT.x = abs(PIVOT.x) < _V_CW_MinimalRadius.x ? _V_CW_MinimalRadius.x * SIGN(PIVOT.x) : PIVOT.x;
		float radius = PIVOT.x;

		float angle = _V_CW_Angle.x * SIGN(radius);
		float l = PI_2 * radius * (angle / 360);

		float3 absZ = abs(PIVOT.zzz - float3(v0.z, v1.z, v2.z)) / l;
		float3 smoothAbsZ = Smooth3(absZ);


		if(v0.z < PIVOT.z)
		{
			Spiral_H_Rotate_Z_Negative(v0, PIVOT, absZ.x, smoothAbsZ.x, l, angle);
		}
		if(v1.z < PIVOT.z)
		{
			Spiral_H_Rotate_Z_Negative(v1, PIVOT, absZ.y, smoothAbsZ.y, l, angle);
		}
		if(v2.z < PIVOT.z)
		{
			Spiral_H_Rotate_Z_Negative(v2, PIVOT, absZ.z, smoothAbsZ.z, l, angle);
		}

		vertex = mul(unity_WorldToObject, float4(v0, 1));
		normal = normalize(mul((float3x3)unity_WorldToObject, normalize(cross(v2 - v0, v1 - v0))));

	#elif defined(BENDTYPE_SPIRAL_HORIZONTAL_AXIS_Z_POSITIVE)
			
		PIVOT.x = abs(PIVOT.x) < _V_CW_MinimalRadius.x ? _V_CW_MinimalRadius.x * SIGN(PIVOT.x) : PIVOT.x;
		float radius = PIVOT.x;

		float angle = _V_CW_Angle.x * SIGN(radius);
		float l = PI_2 * radius * (angle / 360);

		float3 absZ = abs(PIVOT.zzz - float3(v0.z, v1.z, v2.z)) / l;
		float3 smoothAbsZ = Smooth3(absZ);


		if(v0.z > PIVOT.z)
		{
			Spiral_H_Rotate_Z_Positive(v0, PIVOT, absZ.x, smoothAbsZ.x, l, angle);
		}
		if(v1.z > PIVOT.z)
		{
			Spiral_H_Rotate_Z_Positive(v1, PIVOT, absZ.y, smoothAbsZ.y, l, angle);
		}
		if(v2.z > PIVOT.z)
		{
			Spiral_H_Rotate_Z_Positive(v2, PIVOT, absZ.z, smoothAbsZ.z, l, angle);
		}

		vertex = mul(unity_WorldToObject, float4(v0, 1));
		normal = normalize(mul((float3x3)unity_WorldToObject, normalize(cross(v2 - v0, v1 - v0))));

	#elif defined(BENDTYPE_SPIRAL_HORIZONTAL_DOUBLE_AXIS_X)

		float2 p = float2(PIVOT.z, PIVOT_2.z);
		float2 radius = abs(p) < _V_CW_MinimalRadius ? _V_CW_MinimalRadius * SIGN2(p) : p;
		
		float2 angle = _V_CW_Angle * SIGN2(radius);
		float2 l = PI_2 * radius * (angle / 360);
		

		float3 absX = abs(PIVOT.xxx - float3(v0.x, v1.x, v2.x)) / l.x;
		float3 smoothAbsX = Smooth3(absX);

		float3 absX_2 = abs(PIVOT_2.xxx - float3(v0.x, v1.x, v2.x)) / l.y;
		float3 smoothAbsX_2 = Smooth3(absX_2);


		if(v0.x < PIVOT.x)
		{
			PIVOT.z = radius.x;
			Spiral_H_Rotate_X_Positive(v0, PIVOT, absX.x, smoothAbsX.x, l.x, angle.x);
		}
		else if(v0.x > PIVOT_2.x)
		{
			PIVOT_2.z = radius.y;
			Spiral_H_Rotate_X_Negative(v0,  PIVOT_2, absX_2.x, smoothAbsX_2.x, l.y, angle.y);
		}

		if(v1.x < PIVOT.x)
		{
			PIVOT.z = radius.x;
			Spiral_H_Rotate_X_Positive(v1, PIVOT, absX.y, smoothAbsX.y, l.x, angle.x);
		}
		else if(v1.x >  PIVOT_2.x)
		{
			PIVOT_2.z = radius.y;
			Spiral_H_Rotate_X_Negative(v1,  PIVOT_2, absX_2.y, smoothAbsX_2.y, l.y, angle.y);
		}

		if(v2.x < PIVOT.x)
		{
			PIVOT.z = radius.x;
			Spiral_H_Rotate_X_Positive(v2, PIVOT, absX.z, smoothAbsX.z, l.x, angle.x);
		}
		else if(v2.x >  PIVOT_2.x)
		{
			PIVOT_2.z = radius.y;
			Spiral_H_Rotate_X_Negative(v2,  PIVOT_2, absX_2.z, smoothAbsX_2.z, l.y, angle.y);
		}

		vertex = mul(unity_WorldToObject, float4(v0, 1));
		normal = normalize(mul((float3x3)unity_WorldToObject, normalize(cross(v2 - v0, v1 - v0))));

	#elif defined(BENDTYPE_SPIRAL_HORIZONTAL_DOUBLE_AXIS_Z)

		float2 p = float2(PIVOT.x, PIVOT_2.x);
		float2 radius = abs(p) < _V_CW_MinimalRadius ? _V_CW_MinimalRadius * SIGN2(p) : p;
			
		float2 angle = _V_CW_Angle * SIGN2(radius);
		float2 l = PI_2 * radius * (angle / 360);


		float3 absZ = abs(PIVOT.zzz - float3(v0.z, v1.z, v2.z)) / l.x;
		float3 smoothAbsZ = Smooth3(absZ);

		float3 absZ_2 = abs(PIVOT_2.zzz - float3(v0.z, v1.z, v2.z)) / l.y;
		float3 smoothAbsZ_2 = Smooth3(absZ_2);


		if(v0.z < PIVOT.z)
		{
			PIVOT.x = radius.x;
			Spiral_H_Rotate_Z_Negative(v0, PIVOT, absZ.x, smoothAbsZ.x, l.x, angle.x);
		}
		else if(v0.z > PIVOT_2.z)
		{
			PIVOT_2.x = radius.y;
			Spiral_H_Rotate_Z_Positive(v0, PIVOT_2, absZ_2.x, smoothAbsZ_2.x, l.y, angle.y);
		}

		if(v1.z < PIVOT.z)
		{
			PIVOT.x = radius.x;
			Spiral_H_Rotate_Z_Negative(v1, PIVOT, absZ.y, smoothAbsZ.y, l.x, angle.x);
		}
		else if(v1.z > PIVOT_2.z)
		{
			PIVOT_2.x = radius.y;
			Spiral_H_Rotate_Z_Positive(v1, PIVOT_2, absZ_2.y, smoothAbsZ_2.y, l.y, angle.y);
		}

		if(v2.z < PIVOT.z)
		{
			PIVOT.x = radius.x;
			Spiral_H_Rotate_Z_Negative(v2, PIVOT, absZ.z, smoothAbsZ.z, l.x, angle.x);
		} 
		else if(v2.z > PIVOT_2.z)
		{
			PIVOT_2.x = radius.y;
			Spiral_H_Rotate_Z_Positive(v2, PIVOT_2, absZ_2.z, smoothAbsZ_2.z, l.y, angle.y);
		}


		vertex = mul(unity_WorldToObject, float4(v0, 1));
		normal = normalize(mul((float3x3)unity_WorldToObject, normalize(cross(v2 - v0, v1 - v0))));

	#elif defined(BENDTYPE_SPIRAL_HORIZONTAL_ROLLOFF_AXIS_X)

		PIVOT_2.x = PIVOT.x + _V_CW_Rolloff;	
		PIVOT_2.yz = PIVOT.yz;

		PIVOT.x -= _V_CW_Rolloff;
		


		float radius = abs(PIVOT.z) < _V_CW_MinimalRadius.x ? _V_CW_MinimalRadius.x * SIGN(PIVOT.z) : PIVOT.z;
		
		float angle = _V_CW_Angle.x * SIGN(radius);
		float l = PI_2 * radius * (angle / 360);
		

		float3 absX = abs(PIVOT.xxx - float3(v0.x, v1.x, v2.x)) / l;
		float3 smoothAbsX = Smooth3(absX);

		float3 absX_2 = abs(PIVOT_2.xxx - float3(v0.x, v1.x, v2.x)) / l;
		float3 smoothAbsX_2 = Smooth3(absX_2);


		if(v0.x < PIVOT.x)
		{
			PIVOT.z = radius;
			Spiral_H_Rotate_X_Positive(v0, PIVOT, absX.x, smoothAbsX.x, l, angle);
		}
		else if(v0.x > PIVOT_2.x)
		{
			PIVOT_2.z = radius;
			Spiral_H_Rotate_X_Negative(v0,  PIVOT_2, absX_2.x, smoothAbsX_2.x, l, angle);
		}

		if(v1.x < PIVOT.x)
		{
			PIVOT.z = radius;
			Spiral_H_Rotate_X_Positive(v1, PIVOT, absX.y, smoothAbsX.y, l, angle);
		}
		else if(v1.x >  PIVOT_2.x)
		{
			PIVOT_2.z = radius;
			Spiral_H_Rotate_X_Negative(v1,  PIVOT_2, absX_2.y, smoothAbsX_2.y, l, angle);
		}

		if(v2.x < PIVOT.x)
		{
			PIVOT.z = radius;
			Spiral_H_Rotate_X_Positive(v2, PIVOT, absX.z, smoothAbsX.z, l, angle);
		}
		else if(v2.x >  PIVOT_2.x)
		{
			PIVOT_2.z = radius;
			Spiral_H_Rotate_X_Negative(v2,  PIVOT_2, absX_2.z, smoothAbsX_2.z, l, angle);
		}

		vertex = mul(unity_WorldToObject, float4(v0, 1));
		normal = normalize(mul((float3x3)unity_WorldToObject, normalize(cross(v2 - v0, v1 - v0))));

	#elif defined(BENDTYPE_SPIRAL_HORIZONTAL_ROLLOFF_AXIS_Z)

		PIVOT_2.z = PIVOT.z + _V_CW_Rolloff;	
		PIVOT_2.xy = PIVOT.xy;

        PIVOT.z -= _V_CW_Rolloff;


		
		float radius = abs(PIVOT.x) < _V_CW_MinimalRadius.x ? _V_CW_MinimalRadius.x * SIGN(PIVOT.x) : PIVOT.x;
			
		float angle = _V_CW_Angle.x * SIGN(radius);
		float l = PI_2 * radius * (angle / 360);


		float3 absZ = abs(PIVOT.zzz - float3(v0.z, v1.z, v2.z)) / l;
		float3 smoothAbsZ = Smooth3(absZ);

		float3 absZ_2 = abs(PIVOT_2.zzz - float3(v0.z, v1.z, v2.z)) / l;
		float3 smoothAbsZ_2 = Smooth3(absZ_2);


		if(v0.z < PIVOT.z)
		{
			PIVOT.x = radius;
			Spiral_H_Rotate_Z_Negative(v0, PIVOT, absZ.x, smoothAbsZ.x, l, angle);
		}
		else if(v0.z > PIVOT_2.z)
		{
			PIVOT_2.x = radius;
			Spiral_H_Rotate_Z_Positive(v0, PIVOT_2, absZ_2.x, smoothAbsZ_2.x, l, angle);
		}

		if(v1.z < PIVOT.z)
		{
			PIVOT.x = radius;
			Spiral_H_Rotate_Z_Negative(v1, PIVOT, absZ.y, smoothAbsZ.y, l, angle);
		}
		else if(v1.z > PIVOT_2.z)
		{
			PIVOT_2.x = radius;
			Spiral_H_Rotate_Z_Positive(v1, PIVOT_2, absZ_2.y, smoothAbsZ_2.y, l, angle);
		}

		if(v2.z < PIVOT.z)
		{
			PIVOT.x = radius;
			Spiral_H_Rotate_Z_Negative(v2, PIVOT, absZ.z, smoothAbsZ.z, l, angle);
		} 
		else if(v2.z > PIVOT_2.z)
		{
			PIVOT_2.x = radius;
			Spiral_H_Rotate_Z_Positive(v2, PIVOT_2, absZ_2.z, smoothAbsZ_2.z, l, angle);
		}


		vertex = mul(unity_WorldToObject, float4(v0, 1));
		normal = normalize(mul((float3x3)unity_WorldToObject, normalize(cross(v2 - v0, v1 - v0))));


	#elif defined(BENDTYPE_SPIRAL_VERTICAL_AXIS_X_POSITIVE)

		PIVOT.y = abs(PIVOT.y) < _V_CW_MinimalRadius.x ? _V_CW_MinimalRadius.x * SIGN(PIVOT.y) : PIVOT.y;
		float radius = PIVOT.y;

		float angle = _V_CW_Angle.x * SIGN(radius);
		float l = PI_2 * radius * (angle / 360);

		float3 absX = abs(PIVOT.xxx - float3(v0.x, v1.x, v2.x)) / l;
		float3 smoothAbsX = Smooth3(absX);


		if(v0.x > PIVOT.x)
		{
			Spiral_V_Rotate_X_Negative(v0, PIVOT, absX.x, smoothAbsX.x, l, angle);
		}
		if(v1.x > PIVOT.x)
		{
			Spiral_V_Rotate_X_Negative(v1, PIVOT, absX.y, smoothAbsX.y, l, angle);
		}
		if(v2.x > PIVOT.x)
		{
			Spiral_V_Rotate_X_Negative(v2, PIVOT, absX.z, smoothAbsX.z, l, angle);
		}


		vertex = mul(unity_WorldToObject, float4(v0, 1));
		normal = normalize(mul((float3x3)unity_WorldToObject, normalize(cross(v2 - v0, v1 - v0))));

	#elif defined(BENDTYPE_SPIRAL_VERTICAL_AXIS_X_NEGATIVE)

		PIVOT.y = abs(PIVOT.y) < _V_CW_MinimalRadius.x ? _V_CW_MinimalRadius.x * SIGN(PIVOT.y) : PIVOT.y;
		float radius = PIVOT.y;

		float angle = _V_CW_Angle.x * SIGN(radius);
		float l = PI_2 * radius * (angle / 360);

		float3 absX = abs(PIVOT.xxx - float3(v0.x, v1.x, v2.x)) / l;
		float3 smoothAbsX = Smooth3(absX);


		if(v0.x < PIVOT.x)
		{
			Spiral_V_Rotate_X_Positive(v0, PIVOT, absX.x, smoothAbsX.x, l, angle);
		}
		if(v1.x < PIVOT.x)
		{
			Spiral_V_Rotate_X_Positive(v1, PIVOT, absX.y, smoothAbsX.y, l, angle);
		}
		if(v2.x < PIVOT.x)
		{
			Spiral_V_Rotate_X_Positive(v2, PIVOT, absX.z, smoothAbsX.z, l, angle);
		}


		vertex = mul(unity_WorldToObject, float4(v0, 1));
		normal = normalize(mul((float3x3)unity_WorldToObject, normalize(cross(v2 - v0, v1 - v0))));

	#elif defined(BENDTYPE_SPIRAL_VERTICAL_AXIS_Z_NEGATIVE)

		PIVOT.y = abs(PIVOT.y) < _V_CW_MinimalRadius.x ? _V_CW_MinimalRadius.x * SIGN(PIVOT.y) : PIVOT.y;
		float radius = PIVOT.y;

		float angle = _V_CW_Angle.x * SIGN(radius);
		float l = PI_2 * radius * (angle / 360);

		float3 absZ = abs(PIVOT.zzz - float3(v0.z, v1.z, v2.z)) / l;
		float3 smoothAbsX = Smooth3(absZ);

		if(v0.z < PIVOT.z)
		{
			Spiral_V_Rotate_Z_Negative(v0, PIVOT, absZ.x, smoothAbsX.x, l, angle);
		}
		if(v1.z < PIVOT.z)
		{
			Spiral_V_Rotate_Z_Negative(v1, PIVOT, absZ.y, smoothAbsX.y, l, angle);
		}
		if(v2.z < PIVOT.z)
		{
			Spiral_V_Rotate_Z_Negative(v2, PIVOT, absZ.z, smoothAbsX.z, l, angle);
		}

		vertex = mul(unity_WorldToObject, float4(v0, 1));
		normal = normalize(mul((float3x3)unity_WorldToObject, normalize(cross(v2 - v0, v1 - v0))));

	#elif defined(BENDTYPE_SPIRAL_VERTICAL_AXIS_Z_POSITIVE)
			
		PIVOT.y = abs(PIVOT.y) < _V_CW_MinimalRadius.x ? _V_CW_MinimalRadius.x * SIGN(PIVOT.y) : PIVOT.y;
		float radius = PIVOT.y;

		float angle = _V_CW_Angle.x * SIGN(radius);
		float l = PI_2 * radius * (angle / 360);

		float3 absZ = abs(PIVOT.zzz - float3(v0.z, v1.z, v2.z)) / l;
		float3 smoothAbsX = Smooth3(absZ);


		if(v0.z > PIVOT.z)
		{
			Spiral_V_Rotate_Z_Positive(v0, PIVOT, absZ.x, smoothAbsX.x, l, angle);
		}
		if(v1.z > PIVOT.z)
		{
			Spiral_V_Rotate_Z_Positive(v1, PIVOT, absZ.y, smoothAbsX.y, l, angle);
		}
		if(v2.z > PIVOT.z)
		{
			Spiral_V_Rotate_Z_Positive(v2, PIVOT, absZ.z, smoothAbsX.z, l, angle);
		}


		vertex = mul(unity_WorldToObject, float4(v0, 1));
		normal = normalize(mul((float3x3)unity_WorldToObject, normalize(cross(v2 - v0, v1 - v0))));

	#elif defined(BENDTYPE_SPIRAL_VERTICAL_DOUBLE_AXIS_X)
	
		float2 p = float2(PIVOT.y, PIVOT_2.y);
		float2 radius = abs(p) < _V_CW_MinimalRadius ? _V_CW_MinimalRadius * SIGN2(p) : p;			

		float2 angle = _V_CW_Angle * SIGN2(radius);
		float2 l = PI_2 * radius * (angle / 360);


		float3 absX = abs(PIVOT.xxx - float3(v0.x, v1.x, v2.x)) / l.x;
		float3 smoothAbsX = Smooth3(absX);

		float3 absX_2 = abs(PIVOT_2.xxx - float3(v0.x, v1.x, v2.x)) / l.y;
		float3 smoothAbsX_2 = Smooth3(absX_2);


		if(v0.x < PIVOT.x)
		{
			PIVOT.y = radius.x;
			Spiral_V_Rotate_X_Positive(v0, PIVOT, absX.x, smoothAbsX.x, l.x, angle.x);
		}
		else if(v0.x > PIVOT_2.x)
		{
			PIVOT_2.y = radius.y;
			Spiral_V_Rotate_X_Negative(v0, PIVOT_2, absX_2.x, smoothAbsX_2.x, l.y, angle.y);
		}

		if(v1.x < PIVOT.x)
		{
			PIVOT.y = radius.x;
			Spiral_V_Rotate_X_Positive(v1, PIVOT, absX.y, smoothAbsX.y, l.x, angle.x);
		}
		else if(v1.x > PIVOT_2.x)
		{
			PIVOT_2.y = radius.y;
			Spiral_V_Rotate_X_Negative(v1, PIVOT_2, absX_2.y, smoothAbsX_2.y, l.y, angle.y);
		}

		if(v2.x < PIVOT.x)
		{
			PIVOT.y = radius.x;
			Spiral_V_Rotate_X_Positive(v2, PIVOT, absX.z, smoothAbsX.z, l.x, angle.x);
		}
		else if(v2.x > PIVOT_2.x)
		{
			PIVOT_2.y = radius.y;
			Spiral_V_Rotate_X_Negative(v2, PIVOT_2, absX_2.z, smoothAbsX_2.z, l.y, angle.y);
		}


		vertex = mul(unity_WorldToObject, float4(v0, 1));
		normal = normalize(mul((float3x3)unity_WorldToObject, normalize(cross(v2 - v0, v1 - v0))));

	#elif defined(BENDTYPE_SPIRAL_VERTICAL_DOUBLE_AXIS_Z)

		float2 p = float2(PIVOT.y, PIVOT_2.y);
		float2 radius = abs(p) < _V_CW_MinimalRadius ? _V_CW_MinimalRadius * SIGN2(p) : p;
	
		float2 angle = _V_CW_Angle * SIGN2(radius);
		float2 l = PI_2 * radius * (angle / 360);


		float3 absZ = abs(PIVOT.zzz - float3(v0.z, v1.z, v2.z)) / l.x;
		float3 smoothAbsX = Smooth3(absZ);

		float3 absZ_2 = abs(PIVOT_2.zzz - float3(v0.z, v1.z, v2.z)) / l.y;
		float3 smoothAbsX_2 = Smooth3(absZ_2);


		if(v0.z < PIVOT.z)
		{
			PIVOT.y = radius.x;
			Spiral_V_Rotate_Z_Negative(v0, PIVOT, absZ.x, smoothAbsX.x, l.x, angle.x);
		}
		else if(v0.z > PIVOT_2.z)
		{
			PIVOT_2.y = radius.y;
			Spiral_V_Rotate_Z_Positive(v0, PIVOT_2, absZ_2.x, smoothAbsX_2.x, l.y, angle.y);
		}

		if(v1.z < PIVOT.z)
		{
			PIVOT.y = radius.x;
			Spiral_V_Rotate_Z_Negative(v1, PIVOT, absZ.y, smoothAbsX.y, l.x, angle.x);
		}
		else if(v1.z > PIVOT_2.z)
		{
			PIVOT_2.y = radius.y;
			Spiral_V_Rotate_Z_Positive(v1, PIVOT_2, absZ_2.y, smoothAbsX_2.y, l.y, angle.y);
		}

		if(v2.z < PIVOT.z)
		{
			PIVOT.y = radius.x;
			Spiral_V_Rotate_Z_Negative(v2, PIVOT, absZ.z, smoothAbsX.z, l.x, angle.x);
		}
		else if(v2.z > PIVOT_2.z)
		{
			PIVOT_2.y = radius.y;
			Spiral_V_Rotate_Z_Positive(v2, PIVOT_2, absZ_2.z, smoothAbsX_2.z, l.y, angle.y);
		}

		vertex = mul(unity_WorldToObject, float4(v0, 1));
		normal = normalize(mul((float3x3)unity_WorldToObject, normalize(cross(v2 - v0, v1 - v0))));
	
	#elif defined(BENDTYPE_SPIRAL_VERTICAL_ROLLOFF_AXIS_X)

		PIVOT_2.x = PIVOT.x + _V_CW_Rolloff;	
		PIVOT_2.yz = PIVOT.yz;

		PIVOT.x -= _V_CW_Rolloff;

				
		float radius = abs(PIVOT.y) < _V_CW_MinimalRadius.x ? _V_CW_MinimalRadius.x * SIGN(PIVOT.y) : PIVOT.y;			

		float angle = _V_CW_Angle.x * SIGN(radius);
		float l = PI_2 * radius * (angle / 360);


		float3 absX = abs(PIVOT.xxx - float3(v0.x, v1.x, v2.x)) / l;
		float3 smoothAbsX = Smooth3(absX);

		float3 absX_2 = abs(PIVOT_2.xxx - float3(v0.x, v1.x, v2.x)) / l;
		float3 smoothAbsX_2 = Smooth3(absX_2);


		if(v0.x < PIVOT.x)
		{
			PIVOT.y = radius;
			Spiral_V_Rotate_X_Positive(v0, PIVOT, absX.x, smoothAbsX.x, l, angle);
		}
		else if(v0.x > PIVOT_2.x)
		{
			PIVOT_2.y = radius;
			Spiral_V_Rotate_X_Negative(v0, PIVOT_2, absX_2.x, smoothAbsX_2.x, l, angle);
		}

		if(v1.x < PIVOT.x)
		{
			PIVOT.y = radius;
			Spiral_V_Rotate_X_Positive(v1, PIVOT, absX.y, smoothAbsX.y, l, angle);
		}
		else if(v1.x > PIVOT_2.x)
		{
			PIVOT_2.y = radius;
			Spiral_V_Rotate_X_Negative(v1, PIVOT_2, absX_2.y, smoothAbsX_2.y, l, angle);
		}

		if(v2.x < PIVOT.x)
		{
			PIVOT.y = radius;
			Spiral_V_Rotate_X_Positive(v2, PIVOT, absX.z, smoothAbsX.z, l, angle);
		}
		else if(v2.x > PIVOT_2.x)
		{
			PIVOT_2.y = radius;
			Spiral_V_Rotate_X_Negative(v2, PIVOT_2, absX_2.z, smoothAbsX_2.z, l, angle);
		}


		vertex = mul(unity_WorldToObject, float4(v0, 1));
		normal = normalize(mul((float3x3)unity_WorldToObject, normalize(cross(v2 - v0, v1 - v0))));

	#elif defined(BENDTYPE_SPIRAL_VERTICAL_ROLLOFF_AXIS_Z)

		PIVOT_2.z = PIVOT.z + _V_CW_Rolloff;	
		PIVOT_2.xy = PIVOT.xy;

		PIVOT.z -= _V_CW_Rolloff;


		float radius = abs(PIVOT.y) < _V_CW_MinimalRadius.x ? _V_CW_MinimalRadius.x * SIGN(PIVOT.y) : PIVOT.y;
	
		float angle = _V_CW_Angle.x * SIGN(radius);
		float l = PI_2 * radius * (angle / 360);


		float3 absZ = abs(PIVOT.zzz - float3(v0.z, v1.z, v2.z)) / l;
		float3 smoothAbsX = Smooth3(absZ);

		float3 absZ_2 = abs(PIVOT_2.zzz - float3(v0.z, v1.z, v2.z)) / l;
		float3 smoothAbsX_2 = Smooth3(absZ_2);


		if(v0.z < PIVOT.z)
		{
			PIVOT.y = radius;
			Spiral_V_Rotate_Z_Negative(v0, PIVOT, absZ.x, smoothAbsX.x, l, angle);
		}
		else if(v0.z > PIVOT_2.z)
		{
			PIVOT_2.y = radius;
			Spiral_V_Rotate_Z_Positive(v0, PIVOT_2, absZ_2.x, smoothAbsX_2.x, l, angle);
		}

		if(v1.z < PIVOT.z)
		{
			PIVOT.y = radius;
			Spiral_V_Rotate_Z_Negative(v1, PIVOT, absZ.y, smoothAbsX.y, l, angle);
		}
		else if(v1.z > PIVOT_2.z)
		{
			PIVOT_2.y = radius;
			Spiral_V_Rotate_Z_Positive(v1, PIVOT_2, absZ_2.y, smoothAbsX_2.y, l, angle);
		}

		if(v2.z < PIVOT.z)
		{
			PIVOT.y = radius;
			Spiral_V_Rotate_Z_Negative(v2, PIVOT, absZ.z, smoothAbsX.z, l, angle);
		}
		else if(v2.z > PIVOT_2.z)
		{
			PIVOT_2.y = radius;
			Spiral_V_Rotate_Z_Positive(v2, PIVOT_2, absZ_2.z, smoothAbsX_2.z, l, angle);
		}


		vertex = mul(unity_WorldToObject, float4(v0, 1));
		normal = normalize(mul((float3x3)unity_WorldToObject, normalize(cross(v2 - v0, v1 - v0))));

	#else

		//Do nothing

	#endif
}

inline void V_CW_TransformPointAndNormal(inout float4 vertex, inout float3 normal, float4 tangent)
{	
	float3 worldPos = mul(unity_ObjectToWorld, vertex).xyz; 
	float3 worldNormal = UnityObjectToWorldNormal(normal);
	float3 worldTangent = UnityObjectToWorldDir(tangent.xyz);
	float3 worldBinormal = cross(worldNormal, worldTangent) * -1;// * tangent.w;

	V_CW_TransformPointAndNormal(vertex, normal, worldPos, worldTangent, worldBinormal);
}



//Defines for integration
#define CURVED_WORLD_ENABLED
#define CURVED_WORLD_TRANSFORM_POINT_AND_NORMAL(vertex,normal,tangent) V_CW_TransformPointAndNormal(vertex, normal, tangent);
#define CURVED_WORLD_TRANSFORM_POINT(vertex)                           V_CW_TransformPoint(vertex);

#endif 
