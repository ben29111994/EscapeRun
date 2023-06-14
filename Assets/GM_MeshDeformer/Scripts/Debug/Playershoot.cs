using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public enum ShotType
{
    NORMAL,
    ADDITIVE
}

public class Playershoot : MonoBehaviour
{
    [SerializeField] Transform bulletPrefab;
    public int shotPower = 2;
    public ShotType shotType;

    public Text shotPowerText;

    private float mouseSensitivity = 100.0f;
    private float clampAngle = 80.0f;

    private float rotY = 0.0f; // rotation around the up/y axis
    private float rotX = 0.0f; // rotation around the right/x axis

    void Start()
    {
        Vector3 rot = transform.localRotation.eulerAngles;
        rotY = rot.y;
        rotX = rot.x;

        Cursor.lockState = CursorLockMode.Locked;

        shotPower = Mathf.Clamp(shotPower, 1, 20);
        shotPowerText.text = shotPower.ToString() + " (Scroll to change)";
    }

    void Update()
    {
    
    }
}
