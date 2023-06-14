using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using NWH.VehiclePhysics;


public class tt : MonoBehaviour
{
    public Transform offsetCamera;
    public SwipeControl swipeControl;
    public VehicleController vehicleController;

    private void Update()
    {
        MoveControl();
    }

    private void MoveControl()
    {
        float x = swipeControl.deltaTouchFixed.x * 0.75f;
        vehicleController.input.Horizontal = x;

        float v = (swipeControl.isHold) ? 1 : 0;
        vehicleController.input.Vertical = 1;
    }

    private void FixedUpdate()
    {
        CameraFollow();
    }

    private void CameraFollow()
    {
        Vector3 tarPos = offsetCamera.position;
        tarPos.z = transform.position.z;
        offsetCamera.position = Vector3.Lerp(offsetCamera.position, tarPos, 4 * Time.deltaTime);
    }
}
