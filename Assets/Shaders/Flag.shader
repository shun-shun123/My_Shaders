Shader "Custom/Flag" {
	Properties {
		_MainTex ("Main Texture", 2D) = "white"{}
	}
	SubShader {
		Tags {"RenderType" = "Opaque"}
		LOD 200
		Cull off

		CGPROGRAM
		#pragma surface surf Lambert vertex:vert
		#pragma target 3.0

		sampler2D _MainTex;
		
		struct Input {
			float2 uv_MainTex;
		};

		void vert(inout appdata_full v, out Input o) {
			UNITY_INITIALIZE_OUTPUT(Input, o);
			float amp = 0.5 * sin(_Time * 100 + v.vertex.x * 100);
			float del = 0.5 * cos(_Time * 100 + v.vertex.z * 100);
			v.vertex.xyz = float3(v.vertex.x + del, v.vertex.y + amp, v.vertex.z);
		}

		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}
	Fallback "Diffuse"
}