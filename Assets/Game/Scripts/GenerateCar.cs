using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GenerateCar : MonoBehaviour
{
    public GameObject finishObject;
    public GameObject levelObject;

    public GameObject car1Trigger;
    public List<GameObject> listCar1Trigger = new List<GameObject>();

    public GameObject car2Trigger;
    public List<GameObject> listCar2Trigger = new List<GameObject>();

    public List<Cars> listCars = new List<Cars>();
    public List<Cars> listCarsMoving = new List<Cars>();
    public List<Cars> listBigCars = new List<Cars>();

    [System.Serializable]
    public class Cars
    {
        public CarAuto carPrefab;
        public List<CarAuto> listCar = new List<CarAuto>();
    }


    private float currentPosZ;

    [Header("Input Data")]
    public List<InputData> listInputData = new List<InputData>();

    [System.Serializable]
    public class InputData
    {
        public float Distace;
        public float Percent_Car;
        public float Percent_BigCar;
        public bool IsMoving;
    }

    public void Awake()
    {
        Init();
    }

    private void Init()
    {
        for (int k = 0; k < listCars.Count; k++)
        {
            for(int i = 0; i < 200; i++)
            {
                CarAuto _c = Instantiate(listCars[k].carPrefab, transform);
                _c.gameObject.SetActive(false);
                listCars[k].listCar.Add(_c);
            }
        }

        for (int k = 0; k < listBigCars.Count; k++)
        {
            for (int i = 0; i < 100; i++)
            {
                CarAuto _c = Instantiate(listBigCars[k].carPrefab, transform);
                _c.gameObject.SetActive(false);
                listBigCars[k].listCar.Add(_c);
            }
        }   
    }

    private void Refresh()
    {
        for (int i = 0; i < listCars.Count; i++)
        {
            for(int k = 0; k < listCars[i].listCar.Count; k++)
            {
                listCars[i].listCar[i].Refresh();
            }
        }

        for (int i = 0; i < listBigCars.Count; i++)
        {
            for (int k = 0; k < listBigCars[i].listCar.Count; k++)
            {
                listBigCars[i].listCar[k].Refresh();
            }
        }

        currentPosZ = 100.0f;
    }

    public void GenerateRoad()
    {
        levelObject = Instantiate(new GameObject());
        levelObject.name = "Level n";
        finishObject.SetActive(true);

        Refresh();

        for (int i = 0; i < listInputData.Count; i++)
        {
            float _distance = listInputData[i].Distace;
            float _percentCar = listInputData[i].Percent_Car;
            float _percentBigCar = listInputData[i].Percent_BigCar;
            bool _isMoving = listInputData[i].IsMoving;

            if (_isMoving)
            {
                if (i != 0)
                    GenerateBoxCar1(currentPosZ - 5.0f);
            }
            else
            {
                GenerateBoxCar2(currentPosZ - 10.0f);
            }

            for (int k = -6; k <= 6; k += 4)
            {
                Road(k, _distance, _percentCar, _percentBigCar, _isMoving);
            }

            currentPosZ += _distance + 50.0f;

            if (i == listInputData.Count - 1 && _isMoving == false)
            {
                GenerateBoxCar1(currentPosZ - 20.0f);
            }
        }

        GenerateFinishTrigger(currentPosZ + 50.0f);

        //Road(-6.0f, 200.0f, 15, 20, true);
        //Road(-2.0f, 200.0f, 15, 20, true);
        //Road(2.0f, 200.0f, 15, 20, true);
        //Road(6.0f, 200.0f, 15, 20, true);

        //currentPosZ = 350.0f;
        //GenerateBoxCar2(currentPosZ - 10.0f);

        //Road(-6.0f, 100.0f, 100, 5, false);
        //Road(-2.0f, 100.0f, 100, 5, false);
        //Road(2.0f, 100.0f, 100, 5, false);
        //Road(6.0f, 100.0f, 100, 5, false);

        //currentPosZ = 550.0f;
        //GenerateBoxCar1(currentPosZ + 20.0f);
    }

    private void Road(float _x, float _maxZ, float _percentCar,float _percentBigCar,bool isMoving)
    {
        float sizePrevious = 0.0f;
        float sizeNext = 0.0f;
        float currentZ = currentPosZ;

        _maxZ += currentZ;

        while (currentZ < _maxZ)
        {
            int r = Random.Range(0, 100);

            CarAuto _car = GetCar(_percentBigCar,isMoving);
            sizeNext = _car.Size;
            _car.isMoving = isMoving;
            finishObject.transform.SetParent(levelObject.transform);

            Vector3 _pos = new Vector3(_x, _car.transform.position.y, 0.0f);
            _pos.z = currentZ + sizePrevious / 2.0f + sizeNext / 2.0f + Emply();

            if (r < _percentCar)
            {
                _car.transform.SetParent(levelObject.transform);

                _car.Active(_pos);
            }

            sizePrevious = _car.Size;
            currentZ = _pos.z;
        }
    }

    private CarAuto GetCar(float _percentBigCar,bool _isMoving)
    {
        int r = Random.Range(0, 100);

        if (r < _percentBigCar)
        {
            int n = Random.Range(0, listBigCars.Count);

            for (int i = 0; i < listBigCars.Count; i++)
            {
                if (listBigCars[n].listCar[i].gameObject.activeSelf == false) return listBigCars[n].listCar[i];
            }

            CarAuto _c = Instantiate(listBigCars[n].carPrefab,transform);
            _c.gameObject.SetActive(false);
            listBigCars[n].listCar.Add(_c);
            return _c;
        }
        else
        {
            List<Cars> _listCars = new List<Cars>();

            if (_isMoving)
            {
                _listCars = listCarsMoving;
            }
            else
            {
                _listCars = listCars;
            }


            int n = Random.Range(0, _listCars.Count);

            for (int i = 0; i < _listCars[n].listCar.Count; i++)
            {
                if (_listCars[n].listCar[i].gameObject.activeSelf == false) return _listCars[n].listCar[i];
            }

            CarAuto _c = Instantiate(_listCars[n].carPrefab,transform);
            _c.gameObject.SetActive(false);
            _listCars[n].listCar.Add(_c);
            return _c;
        }
    }

    private void GenerateBoxCar1(float _posZ)
    {
        GameObject _obj = Instantiate(car1Trigger, levelObject.transform);
        Vector3 _pos = _obj.transform.position;
        _pos.z = _posZ;
        _obj.transform.position = _pos;

        listCar1Trigger.Add(_obj);
    }

    private void GenerateBoxCar2(float _posZ)
    {
        GameObject _obj = Instantiate(car2Trigger, levelObject.transform);
        Vector3 _pos = _obj.transform.position;
        _pos.z = _posZ;
        _obj.transform.position = _pos;
        listCar2Trigger.Add(_obj);

    }

    private void GenerateFinishTrigger(float _posZ)
    {
        Vector3 _pos = finishObject.transform.position;
        _pos.z = _posZ;
        finishObject.transform.position = _pos;
    }

    private float Emply()
    {
        int r = Random.Range(0, 100);

        if(r < 20)
        {
            return Random.Range(1.0f, 3.0f);
        }
        else
        {
            return Random.Range(0.0f, 1.0f);
        }
    }
}