using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bullet : MonoBehaviour {

    private Rigidbody ridgid;

    private void Awake()
    {
        ridgid = GetComponent<Rigidbody>();
    }

    public void Shoot (Vector3 dir)
    {
        ridgid.velocity = Vector3.zero;
        
        transform.rotation = Quaternion.identity;
        gameObject.SetActive(true);
        ridgid.AddForce(dir.normalized * 2500.0f);
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("SmallCar"))
        {
            CarAuto _ca = collision.gameObject.GetComponent<CarAuto>();

            if(_ca.isEarnCoin == false)
            {
                _ca.isEarnCoin = true;
                _ca.MashEarnCoin();
            }
        }

        gameObject.SetActive(false);
    }
}
