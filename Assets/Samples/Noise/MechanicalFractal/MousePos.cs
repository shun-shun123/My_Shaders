using UnityEngine;

namespace Noise.MechanicalFractal
{

    public class MousePos : MonoBehaviour
    {
        [SerializeField] private Material mat;
        private static readonly int MouseX = Shader.PropertyToID("_MouseX");
        private static readonly int MouseY = Shader.PropertyToID("_MouseY");

        void Update()
        {
            var pos = Input.mousePosition;
            mat.SetFloat(MouseX, pos.x);
            mat.SetFloat(MouseY, pos.y);
        }
    }
}