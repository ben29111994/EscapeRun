using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RoadManager : MonoBehaviour
{
    public Transform cameraMain;
    public GameObject roadPrefab;
    private List<GameObject> listRoad = new List<GameObject>();
    public float currentPosZ;
    public float targetPosZ;

    private void Update()
    {
        UpdatePositionRoadStep();
    }

    private void UpdatePositionRoadStep()
    {
        if (listRoad.Count == 0) return;

        float b = cameraMain.position.z;

        if (b - targetPosZ >= 10.0f)
        {
            targetPosZ += 10.0f;

            GameObject road0 = listRoad[0];
            listRoad.RemoveAt(0);
            listRoad.Add(road0);

            road0.transform.position = Vector3.forward * currentPosZ;
            currentPosZ += 10.0f;
        }
    }

    public void GenerateRoad()
    {
        for(int i = 0; i < 30; i++)
        {
            GameObject _obj = Instantiate(roadPrefab);
            _obj.transform.SetParent(transform);
            listRoad.Add(_obj);
        }

        ResetPosition();
    }

    public void ResetPosition()
    {
        currentPosZ = 0.0f;
        targetPosZ = 30.0f;

        for (int i = 0; i < listRoad.Count; i++)
        {
            listRoad[i].transform.position = Vector3.forward * currentPosZ;
            currentPosZ += 10.0f;
        }
    }
}
