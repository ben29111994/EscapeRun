using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ColliderCar : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Car2"))
        {
            other.gameObject.SetActive(false);
            Main.Instance.ChangeCar2();
        }
        else if (other.CompareTag("Car1"))
        {
            other.gameObject.SetActive(false);  
            Main.Instance.ChangeCar1();
        }
        else if (other.CompareTag("FinishTrigger"))
        {
      //      other.gameObject.SetActive(false);
            Main.Instance.Finish();
        }
    }
}
