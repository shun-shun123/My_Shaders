using UnityEngine;

namespace PostProcess.Scanline
{
    [ExecuteInEditMode, ImageEffectAllowedInSceneView]
    public class Scanline : MonoBehaviour
    {
        [SerializeField] private Material mat;

        private void OnRenderImage(RenderTexture src, RenderTexture dest)
        {
            Graphics.Blit(src, dest, mat);
        }
    }
}