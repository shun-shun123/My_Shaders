Shader "Unlit/Billboard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                // 原点(0, 0, 0)にオブジェクトがあるというていで、モデル、ビュー変換を行う
                float4 mvMatrix = mul(UNITY_MATRIX_MV, float4(0, 0, 0, 1));
                float4 pMatrix = mvMatrix + float4(v.vertex.x, v.vertex.y, 0, 0);
                // float4 pMatrix = mvMatrix + float4(v.vertex.x, v.vertex.y, 0, 0);
                o.vertex = mul(UNITY_MATRIX_P, pMatrix);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
