Shader "Custom/Rim" {
	SubShader {
		Tags {"RenderType" = "Transparent"}
		LOD 200

		CGPROGRAM
		#pragma surface surf Standard alpha:fade
		#pragma target 3.0

		struct Input {
			float3 worldNormal;
			float3 viewDir;
		};

		void surf (Input IN, inout SurfaceOutputStandard o) {
			o.Albedo = fixed4(0.5, 0.5, 0.5, 1);
			float alpha = 1 - abs(dot(IN.viewDir, IN.worldNormal));
			float rim = 1 - abs(dot(IN.viewDir, IN.worldNormal));
			alpha *= 1.5f;
			rim *= 1.5f;
			o.Alpha = alpha;
			o.Emission = fixed4(1, 1, 0, 1) * pow(rim, 3);
		}
		ENDCG
	}
	Fallback "Diffuse"
}