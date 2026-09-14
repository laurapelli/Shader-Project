Shader "Unlit/VertexCubeShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Translation("Translation", vector) = (0,0,0)
        _Rotation("Rotation", vector) = (0,0,0)
        _Scale("Scale", vector) = (1,1,1)
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 100

            Pass
            {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            
            #include "UnityCG.cginc"

            float3 _Translation;
            float3 _Rotation;
            float3 _Scale;
            float4x4 _ViewMatrix;
            float4x4 _ProjectionMatrix;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                //o.vertex = UnityObjectToClipPos(v.vertex);

                float4x4 translationMatrix = float4x4(
                    1, 0, 0, _Translation.x,
                    0, 1, 0, _Translation.y,
                    0, 0, 1, _Translation.z,
                    0, 0, 0, 1
                    );
                float4x4 rotationX = float4x4(
                    1, 0, 0, 0,
                    0, cos(_Rotation.x), sin(_Rotation.x), 0,
                    0, -sin(_Rotation.x), cos(_Rotation.x), 0,
                    0, 0, 0, 1
                    );

                float4x4 rotationY = float4x4(
                    cos(_Rotation.y), 0, -sin(_Rotation.y), 0,
                    0, 1, 0, 0,
                    sin(_Rotation.y), 0, cos(_Rotation.y), 0,
                    0, 0, 0, 1
                    );

                float4x4 rotationZ = float4x4(
                    cos(_Rotation.z), sin(_Rotation.z), 0, 0,
                    -sin(_Rotation.z), cos(_Rotation.z), 0, 0,
                    0, 0, 1, 0,
                    0, 0, 0, 1
                    );

                float4x4 scaleMatrix = float4x4(
                    _Scale.x, 0, 0, 0,
                    0, _Scale.y, 0, 0,
                    0, 0, _Scale.z, 0,
                    0, 0, 0, 1
                    );

                // We calculate all translation, rotation and scale in one matrix
                float4x4 modelMatrix =
                    mul(translationMatrix,
                        mul(rotationX,
                            mul(rotationY,
                                mul(rotationZ, scaleMatrix))));

                // We calculate the new world position of each vertex using the model matrix
                float4 worldPos = mul(modelMatrix, v.vertex);

                // We calculate the clip position of the vertex ( How the camera will see the vertex )
                //o.vertex = UnityObjectToClipPos(worldPos);

                //First we calciulate the biew matric
                float4 viewMatrix = mul(_ViewMatrix, worldPos);

                // Then we calculate the projection matrix
                float4 projectionMatrix = mul(_ProjectionMatrix, viewMatrix);

                o.vertex = projectionMatrix;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}