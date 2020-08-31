Shader "Custom/TrimColor" {
	Properties {
		_MainTex ("Texture", 2D) = "white"{}
		_bRange ("blueRange", Range(0.0, 1.0)) = 1.0
	}

	SubShader {
		Tags {"Queue" = "Transparent"}
		LOD 200

		CGPROGRAM
		#pragma surface surf Standard alpha:fade
		#pragma target 3.0

		struct Input {
			float2 uv_MainTex;
		};

		sampler2D _MainTex;
		float _bRange;

		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 color = tex2D(_MainTex, IN.uv_MainTex);
			o.Albedo = color;
			o.Alpha = (color.b < _bRange) ? 0 : 1;
		}
		ENDCG
	}
	Fallback "Diffuse"
}