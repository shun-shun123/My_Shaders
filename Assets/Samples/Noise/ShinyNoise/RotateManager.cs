using System;
using UnityEngine;

namespace Noise.Shiny
{
    public class RotateManager : MonoBehaviour
    {
        [SerializeField] private Material shinyMaterial;
        private static readonly int Attitude = Shader.PropertyToID("_Attitude");

        private void Start()
        {
            Input.gyro.enabled = true;
        }
        
        private void Update()
        {
            var gyro = Input.gyro;
            Debug.Log($"X: {RadianToDeg(gyro.rotationRate.x)}");
            Debug.Log($"Y: {RadianToDeg(gyro.rotationRate.y)}");
            Debug.Log($"Z: {RadianToDeg(gyro.rotationRate.z)}");
            
            shinyMaterial.SetFloat(Attitude, (float)RadianToDeg(gyro.rotationRate.y) / 180.0f);
        }

        private double RadianToDeg(float rad)
        {
            return (rad * 180.0) / Mathf.PI;
        }
    }
}