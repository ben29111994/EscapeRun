using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CarAuto : MonoBehaviour
{
    public bool isEarnCoin;
    public float Size;
    public bool isMoving;
    public Rigidbody rigid;
    public BoxCollider boxCollider;
    public MeshCollider meshCollider;
    public CapsuleCollider capsuleCollider;
    public GameObject capsuleCollider2;
    public LayerMask layer;

    [Header("Color Car")]
    public bool isChangeColorCar;
    public Material[] mats;
    public Renderer rend;

    private void OnEnable()
    {
        if (isMoving == false)
        {
            if (gameObject.name == "car8(Clone)")
            {
                transform.GetChild(0).gameObject.SetActive(false);
                capsuleCollider2 = Instantiate(GameManager.Instance.car8Collider, transform);
                if(transform.localRotation.x > 0.5f)
                {
                    capsuleCollider2.transform.localPosition = Vector3.up * 1.9f;
                    capsuleCollider2.transform.localEulerAngles = Vector3.right * 180;
                }
            }
        }

    }


    public void Addforce(Vector3 direction)
    {
        isMoving = false;
        direction.y = 0.0f;

        rigid.isKinematic = false;
        rigid.useGravity = true;
        rigid.constraints = RigidbodyConstraints.None;

        rigid.mass = 5.0f;
        rigid.drag = 2.0f;

        rigid.AddForce(direction);
        rigid.AddTorque(Vector3.up * direction.magnitude);
    }

    public void Active(Vector3 _pos)
    {
     
        transform.position = _pos;
        moveSpeed = Random.Range(6.0f, 10.0f);
        gameObject.SetActive(true);

        if (isMoving)
        {
            if (rigid != null)
                rigid.isKinematic = false;
        }
        else
        {
            if (rigid != null)
                rigid.isKinematic = true;
        }

        if (isChangeColorCar)
            rend.material = mats[Random.Range(0, mats.Length)];


    }

    public void Refresh()
    {
        Vector3 _pos = transform.position;
        _pos.x = _pos.z = 0.0f;
        transform.position = _pos;

        gameObject.SetActive(false);
    }

    public float moveSpeed;
    public float distance;

    private void Update()
    {
        if (Main.Instance.car1.gameObject.activeSelf)
        {
            ActiveBoxCollider(true);
        }
        else
        {
            ActiveBoxCollider(false);
        }
    }

    private void FixedUpdate()
    {
        if (isMoving == false || GameManager.Instance.isStart == false) return;

        float a = transform.position.z;
        float b = GameManager.Instance.offsetCamera.position.z;

        if (b - a > 20.0f) return;

        if (a - b < 100.0f)
        {
            IsStuck();

            if (distance < 1.0f) return;

            if (distance > moveSpeed)
            {              
                rigid.velocity = Vector3.forward * moveSpeed;
           //     transform.Translate(Vector3.forward * Time.deltaTime * moveSpeed);
            }
            else
            {
                rigid.velocity = Vector3.forward * distance;
           //     transform.Translate(Vector3.forward * Time.deltaTime * distance);
            }
        }
    }

    public void ActiveBoxCollider(bool isActive)
    {
        if (boxCollider != null)
        {
            boxCollider.enabled = isActive;
        }

        if (meshCollider != null)
        {
            meshCollider.enabled = !isActive;
        }

        if (capsuleCollider2 != null) capsuleCollider2.SetActive(!isActive);
    }

    private bool IsStuck()
    {
        Vector3 myPos = transform.position;
        myPos.y = 1.5f;
        myPos.z +=  Size / 2.0f;

        RaycastHit hit;
        Ray ray = new Ray(myPos, Vector3.forward);


        if(Physics.Raycast(ray,out hit,Mathf.Infinity, layer))
        {
            if(hit.collider != null)
            {
                distance = Vector3.Distance(myPos, hit.point);
                return true;
            }
            else
            {
                return false;
            }

        }

        return false;
    }

    public void MashEarnCoin()
    {
        GameManager.Instance.Vibration();
        GameManager.Instance.main.EarnCoin();
    }
}
