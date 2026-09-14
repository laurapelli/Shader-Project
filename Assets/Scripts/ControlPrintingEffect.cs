using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ControlPrintingEffect : MonoBehaviour
{
    [SerializeField] private Material printMaterial; // Reference to the material using the 3D printing shader
    [SerializeField] private float printSpeed = 0.5f; // Speed at which the object "prints"
    [SerializeField] private float restartDelay = 2.0f; // Delay before restarting the effect
    [SerializeField] private Color topColor = Color.red; // Color of the leading edge
    [SerializeField] private float highlightThickness = 0.05f; // Thickness of the highlight

    private float progress; // Tracks the current printing progress
    private float minHeight; // Minimum height of the object in local space
    private bool isRestarting = false; // To prevent overlapping restarts

    // Start is called before the first frame update
    void Start()
    {
        if (printMaterial == null)
        {
            Debug.LogError("No material assigned to ControlPrintingEffect!");
            return;
        }

        // Calculate the minimum height of the object's mesh
        MeshFilter meshFilter = GetComponent<MeshFilter>();
        if (meshFilter != null)
        {
            Mesh mesh = meshFilter.mesh;
            minHeight = float.MaxValue;

            foreach (Vector3 vertex in mesh.vertices)
            {
                minHeight = Mathf.Min(minHeight, vertex.y);
            }
        }
        else
        {
            Debug.LogError("No MeshFilter found on the GameObject!");
            return;
        }

        // Initialize progress to ensure the object starts fully invisible
        progress = minHeight - 0.1f; // Slightly lower than the minimum height
        printMaterial.SetFloat("_PrintProgress", progress);

        // Set initial values for highlight color and thickness
        printMaterial.SetColor("_TopColor", topColor);
        printMaterial.SetFloat("_HighlightThickness", highlightThickness);
    }

    // Update is called once per frame
    void Update()
    {
        if (isRestarting) return;

        // Gradually increase the printing progress over time
        if (progress < 1f && printMaterial != null)
        {
            progress += printSpeed * Time.deltaTime;
            printMaterial.SetFloat("_PrintProgress", progress);
        }
        else if (progress >= 1f && !isRestarting)
        {
            // Start the restart process
            StartCoroutine(RestartEffect());
        }
    }

    private IEnumerator RestartEffect()
    {
        isRestarting = true;

        // Wait for the specified delay
        yield return new WaitForSeconds(restartDelay);

        // Reset progress
        progress = minHeight - 0.1f; // Reset to below minimum height
        printMaterial.SetFloat("_PrintProgress", progress);

        isRestarting = false;
    }

    public void ChangeHighlightColor(Color newColor)
    {
        topColor = newColor;
        if (printMaterial != null)
        {
            printMaterial.SetColor("_TopColor", topColor);
        }
    }

    public void ChangeHighlightThickness(float newThickness)
    {
        highlightThickness = newThickness;
        if (printMaterial != null)
        {
            printMaterial.SetFloat("_HighlightThickness", highlightThickness);
        }
    }
}
