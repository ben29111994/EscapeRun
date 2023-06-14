using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LoopMap : MonoBehaviour
{
    public float distance;
    private List<GameObject> listObject = new List<GameObject>();
    public Transform cameram;
    private float offsetCamera_Z;

    //private void Awake()
    //{
    //    for(int i = 0; i < transform.childCount; i++)
    //    {
    //        listObject.Add(transform.GetChild(i).gameObject);
    //    }

    //    offsetCamera_Z = cameram.position.z;
    //}

    //private void Start()
    //{
    //    for(int i = 0; i < listObject.Count;i++)
    //    {
    //        Vector3 temp = listObject[i].transform.position;
    //        temp.z = (float)i * distance;
    //        listObject[i].transform.position = temp;
    //    }
    //}

    //private void Update()
    //{
    //    float z1 = listObject[0].transform.position.z;
    //    float z2 = cameram.position.z;

    //    if(z2 - z1 >= (distance + offsetCamera_Z))
    //    {
    //        GameObject obj = listObject[0];
    //        listObject.RemoveAt(0);
    //        obj.transform.position = listObject[listObject.Count - 1].transform.position + Vector3.forward * distance;
    //        listObject.Add(obj);
    //    }
    //}
}
