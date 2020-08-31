// Shader "Custom/shader" {
//     SubShader {
//         Tags {"RenderType" = "Opaque"}
//         LOD 200

//         CGPROGRAM
//         #pragma surface surf Standard
//         #pragma target 3.0

//         struct Input {
//             float2 uv_MainTex;
//             float3 worldNormal;
//             float3 viewDir;
//         };

//         void surf(Input IN, inout SurfaceOutputStandard o) {
//             fixed4 baseColor = fixed4(0.05, 0.1, 0, 1);
//             fixed4 rimColor = fixed4(0.5, 0.7, 0.5, 1);

//             o.Albedo = baseColor;
//             float rim = 1 - abs(dot(IN.viewDir, o.Normal));
//             rim *= 1.5;
//             o.Emission = rimColor * pow(rim, 3);
//         }
//         ENDCG
//     }
//     Fallback "Diffuse"
// }

Shader "Custom/sample" {
    SubShader {
        Tags {"RenderType" = "Queue"}
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard
        #pragma target 3.0

        struct Input {
            float2 uv_MainTex;
            float3 worldNormal;
            float3 viewDir; 
        };

        void surf(Input IN, inout SurfaceOutputStandard o) {
            o.Albedo = fixed4(0.5, 0.2, 0.5, 1);
            float rim = 1 - abs(dot(IN.viewDir, IN.worldNormal));
            fixed4 rimColor = fixed4(0.05, 0.1, 0, 1);
            rim *= 3;
            o.Emission = rimColor * pow(rim, 3.0);
        }
        ENDCG
    }

    Fallback "Diffuse"
}