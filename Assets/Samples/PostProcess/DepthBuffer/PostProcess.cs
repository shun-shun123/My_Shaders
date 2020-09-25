using UnityEngine;

namespace PostProcess.DepthBuffer {
    public class PostProcess : MonoBehaviour
    {
        [SerializeField] private Material mat;
        
        void Start()
        {
            GetComponent<Camera>().depthTextureMode |= DepthTextureMode.Depth;
        }

        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            Graphics.Blit(src, dest, mat);
        }
    }
}