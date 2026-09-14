Shader "Unlit/WaterShader"
{
    Properties
    {
        // Texturas y colores
        _WaterNormal ("Water Normal", 2D) = "bump" {}
        _ShallowColor ("Shallow Color", Color) = (0.7, 0.9, 1.0, 1)
        _DeepColor ("Deep Color", Color) = (0.7, 0.9, 1.0, 1)

        // Parámetros de ondas
        _NormalScale ("Normal Scale", Float) = 1.0
        _Distortion ("Distortion", Float) = 0.5
        _WaterDepth ("Water Depth", Float) = 1.0
        _WaterFalloff ("Water Falloff", Float) = 2.0

        // Parámetros visuales
        _WaterSpecular ("Water Specular", Float) = 0.5
        
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }
        LOD 100

        Pass
        {
            // Configuración de renderizado
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            // Estructuras
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

            // Uniformes
            sampler2D _WaterNormal;
            float4 _WaterNormal_ST;
            float _NormalScale;
            float _Distortion;
            float _WaterDepth;
            float _WaterFalloff;
            float4 _DeepColor;
            float4 _ShallowColor;
            float _WaterSpecular;
           

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _WaterNormal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Generar normales animadas
                float2 uvOffset = i.uv + _Time.y * float2(0.1, 0.1);
                float3 normalMap = UnpackNormal(tex2D(_WaterNormal, uvOffset) * _NormalScale);

                // Simulación de profundidad
                float depth = saturate(pow(_WaterDepth, _WaterFalloff));
                float4 waterColor = lerp(_ShallowColor, _DeepColor, depth);

                // Aplicar distorsión
                float2 distortedUV = i.uv + normalMap.xy * _Distortion;
                float4 distortionColor = tex2D(_WaterNormal, distortedUV);

                // Combinar colores y efectos visuales
                fixed4 finalColor = lerp(waterColor, distortionColor, depth);
                finalColor.rgb *= _WaterSpecular;
                finalColor.a = 0.5; // Transparencia fija

                return finalColor;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}