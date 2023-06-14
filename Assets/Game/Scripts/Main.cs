using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class Main : MonoBehaviour
{
    public static Main Instance;



    private void Awake()
    {
        Instance = this;
    }

    public Transform car1;
    public Transform car2;
    public CarController carController;

    public float ratioVelocityCar1;
    public LayerMask layerTrigger;
    public float currentPositionCar;

    [Header("Reference")]
    public Coin coin;
    public Coin coin2;

    private void LateUpdate()
    {
        if(car1.position.z > car2.position.z)
        {
            currentPositionCar = car1.position.z;
        }
        else
        {
            currentPositionCar = car2.position.z;
        }
    }

    private void FixedUpdate()
    {
        RaycastHit hit;
        Ray ray = new Ray(transform.position, Vector3.forward);

        if(Physics.Raycast(ray,out hit,Mathf.Infinity, layerTrigger))
        {
            
            ratioVelocityCar1 = Vector3.Distance(car1.position, hit.collider.gameObject.transform.position);

            if (hit.collider.gameObject.CompareTag("FinishTrigger"))
            {
                ratioVelocityCar1 = 100.0f;
            }

        }
    }

    public void ChangeCar1()
    {
        car2.gameObject.SetActive(false);

        Vector3 _posCar2 = car2.position;
        _posCar2.y = car1.position.y;
        car1.position = _posCar2;

        car1.gameObject.SetActive(true);
    }

    public void ChangeCar2()
    {
        car1.gameObject.SetActive(false);

        Vector3 _posCar1 = car1.position;
        _posCar1.y = car2.position.y;
        car2.position = _posCar1;

        car2.gameObject.SetActive(true);
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.N))
        {
            ChangeCar1();
        }

        if (Input.GetKeyDown(KeyCode.M))
        {
            ChangeCar2();
        }
    }

    public void Finish()
    {
        carController.FinishAnimation();
    }

    public void CoinAnimation()
    {
        StartCoroutine(C_CoinAnimation());
    }

    private IEnumerator C_CoinAnimation()
    {
        for (int i = 2; i <= 12; i += 2)
        {
            UIManager.Instance.Coin += i;
            if (car1.gameObject.activeSelf == true)
            {
                UIManager.Instance.Coin += 2;
                coin.Active(i);
            }
            else
            {
                UIManager.Instance.Coin += 2;
                coin2.Active(i);
            }

            yield return new WaitForSeconds(0.15f);
        }
    }

    public void EarnCoin()
    {
        if(car1.gameObject.activeSelf == true)
        {
            UIManager.Instance.Coin += 2;
            coin.Active(2);
        }
        else
        {
            UIManager.Instance.Coin += 2;
            coin2.Active(2);
        }
    }
}
