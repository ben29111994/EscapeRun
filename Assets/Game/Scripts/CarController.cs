using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class CarController : MonoBehaviour
{
    public bool isFinish;
    public bool isFail;
    public float moveSpeed;
    public float steerSpeed;
    private float timeDelaySteer;

    [Header("References")]
    public Rigidbody rigidFakeCar;
    public Rigidbody rigid;
    public SwipeControl swipeControl;
    public Transform models;
    public Transform models1;
    public Transform shadow;

    private Vector3 lastVelocity;

    private void OnEnable()
    {
        Vector3 temp = transform.position;
        temp.y = rigidFakeCar.transform.position.y;
        temp.z = rigidFakeCar.transform.position.z;
        rigidFakeCar.transform.position = temp;
    }

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {

    }

    private void FixedUpdate()
    {
        AutoSteer();

        if (GameManager.Instance.isStart == false) return;


        MoveFoward();
        CameraFollow();

    }

    private void LateUpdate()
    {
        lastVelocity = rigid.velocity;
        models1.transform.localRotation = Quaternion.Lerp(models1.localRotation, models.localRotation, 10 * Time.deltaTime);
    }

    private void AutoSteer()
    {
        float _x = swipeControl.deltaTouchPosition.x;

        if (_x == 0)
        {
            if(models.localEulerAngles.y != 0)
            {
                if (timeDelaySteer > 0.0f) timeDelaySteer -= Time.deltaTime;


                if(timeDelaySteer <= 0.0f)
                 models.localRotation = Quaternion.Lerp(models.localRotation, Quaternion.identity, Time.deltaTime * 10.0f);
            }
        }

        Quaternion q = models.localRotation;
        q.z = -models.localRotation.y * 0.8f;
        q.x = q.y = 0.0f;
        models.localRotation = Quaternion.Lerp(models.localRotation, q, Time.deltaTime * 10.0f);
    }

    private void MoveFoward()
    {
        if (isFinish || isFail) return;

        float _x = swipeControl.deltaTouchPosition.x;

        if(Main.Instance.ratioVelocityCar1 < moveSpeed)
        {
            rigid.velocity = transform.forward * (Main.Instance.ratioVelocityCar1 + 20);
        }
        else
        {
            rigid.AddForce(Vector3.forward * 500);
            //      rigid.velocity = transform.forward * moveSpeed + Vector3.right * _x * steerSpeed;
            //      rigid.velocity = transform.forward * moveSpeed + Vector3.right * _x * steerSpeed;
            //      rigid.velocity = transform.forward * moveSpeed + Vector3.right * _x * steerSpeed;
        }

        float _ratio = Mathf.Lerp(0.05f, 1.0f, lastVelocity.magnitude / 30.0f);
        Vector3 vel = rigidFakeCar.velocity;
        vel.x = _x * steerSpeed * _ratio;
        rigidFakeCar.velocity = vel;

        float _xV = Mathf.Abs(_x);
        if (_xV >= 6.0f) GameManager.Instance.Vibration();

        float x = Mathf.Lerp(transform.position.x, rigidFakeCar.transform.position.x, 7.0f * Time.deltaTime);
        Vector3 p = transform.position;
        p.x = x;
        rigid.MovePosition(p);

        //Vector3 vel = rigid.velocity;
        //vel.z = Mathf.Clamp(vel.z,-10.0f, moveSpeed);
        //rigid.velocity = vel;

        models.Rotate(Vector3.up * _x);
        Quaternion q = models.rotation;
        q.y = Mathf.Clamp(q.y, -0.1f, 0.1f);
        models.rotation = q;


        if(_x !=0) timeDelaySteer = 0.08f;      
    }

    private void CameraFollow()
    {
        Vector3 tarPos = GameManager.Instance.offsetCamera.position;
        tarPos.z = transform.position.z;

        if (isFinish) tarPos.x = transform.position.x;

        GameManager.Instance.offsetCamera.position = Vector3.Lerp(GameManager.Instance.offsetCamera.position, tarPos, 12 * Time.deltaTime);
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("BigCar") || collision.gameObject.CompareTag("SmallCar"))
        {
            Vector3 a = transform.position;
            Vector3 b = collision.gameObject.transform.position;
            Vector3 c = a - b;
            c.y = 0.0f;

            rigid.velocity = Vector3.zero;
            rigid.AddForce(c * (lastVelocity.magnitude + 10) * 10.0f);

            isFail = true;

            Vector3 d = (b - a ) * (lastVelocity.magnitude + 10) * 5.0f;
            CarAuto _ca = collision.gameObject.GetComponent<CarAuto>();
            if(_ca!= null)
            {
                _ca.Addforce(d);
            }
            

            GameManager.Instance.Fail();
        }
    }

    public void FinishAnimation()
    {
        isFinish = true;
        GameManager.Instance.FinishAnimation();
        //rigid.velocity = Vector3.zero;
        //rigid.angularVelocity = Vector3.zero;
        //rigid.useGravity = false;

        //Vector3 finishPosition = Main.Instance.finishPosition.position;
        //finishPosition.y = transform.position.y;
        //transform.DOMove(finishPosition, 1.0f);
        //cameraOffset.DORotate(new Vector3(0.0f,70.0f,0.0f), 1.0f);
    }

    private void OnDisable()
    {
        rigid.velocity = Vector3.zero;
    }
}