Shader "Unlit/SimpleTextureShader"
{
    // Unityのマテリアルインスペクターで表示できるプロパティ一覧をここで定義する
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
    }

    // Shaderの本体。最低でも一つのSubShaderから構成される。SubShaderごとにLODなども設定できることことから、ハードウェアごとに区別したりということができる
    SubShader
    {
        Tags { "RenderType" = "Queue" }

        // Passブロックでオブジェクトのジオメトリを一回レンダリングする
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

            // {texture_name}_STの名前でTextureのtilingやoffset情報を取得することができる
            // 中身自体はUnityによって代入されている
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                // float2 tiling_offset_uv = float2(uv.xy * _MainTex_ST.xy + _MainTex_ST.zw); return tiling_offset_uv;
                // これが本当は必要。Tilingとoffsetを考慮するためには。
                // UnityCG.cgincをincludeしている場合には組み込み関数が使える。それがTRANSFORM_TEX関数
                // これを使うということは内部的に_MainTex_STを使っていることとなり宣言を消してしまうとエラーになる。
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col.a = 0.3;
                return col;
            }
            ENDCG
        }
    }
}
