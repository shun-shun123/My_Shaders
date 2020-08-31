// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

Shader "Custom/disolve" {
	Properties {
		_Color ("Color", Color) = (1, 1, 1, 1)
		_MainTex ("Main Texture(RGB)", 2D) = "white"{}
		_DisolveTex ("Disolve Tex(RGB)", 2D) = "white"{}
		_Glossiness ("Smoothness", Range(0, 1)) = 0.5
		_Metallic ("Metallic", Range(0, 1)) = 0.0
		_Threshold ("Threshold", Range(0, 1)) = 0.0
	}
	SubShader {
		Tags {"RenderType" = "Opaque"}
		LOD 200

		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _DisolveTex;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		half _Threshold;
		fixed4 _Color;

		UNITY_INSTANCING_BUFFER_START(Props)
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 m = tex2D(_DisolveTex, IN.uv_MainTex);
			half g = m.r * 0.2 + m.g * 0.7 + m.b * 0.1;
			if (g < _Threshold) {
				// discardはピクセルをレンダリングしない
				discard;
			} else if (g < _Threshold + 0.1 && _Threshold != 0) {
				fixed4 c = fixed4(0, 0, 1, 1);
				fixed4 emit = fixed4(1, 1, 0, 1);
				o.Albedo = c.rgb;
				o.Metallic = _Metallic;
				o.Smoothness = _Glossiness;
				o.Alpha = c.a;
				o.Emission = emit;
			} else {
				fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
				o.Albedo = c.rgb;
				o.Metallic = _Metallic;
				o.Smoothness = _Glossiness;
				o.Alpha = c.a;
			}
		}
		ENDCG
	}
	Fallback "Diffuse"
}