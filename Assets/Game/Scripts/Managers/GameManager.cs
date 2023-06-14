using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;
using MoreMountains.NiceVibrations;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance;

    public bool isGenerateMap;
    public GameObject[] levelPrefab;
    public GameObject[] mapPrefab;
    public GameObject[] curveMaps;
    public string[] manText;

    [Header("Status Game")]
    public bool isComplete;
    public bool isStart;

    [Header("Level Manager")]
    public int levelGame;
    public int levelFixed;

    [Header("References")]
    public GameObject areafinish;
    public RoadManager roadManager;
    public GenerateCar generateCar;
    public Main mainPrefab;
    public Main main;
    public GameObject human;
    public Transform finishTransform;
    public Man man;
    public GameObject car8Collider;

    [Header("Camera")]
    public Transform offsetCamera;
    public Transform mainCamera;
    public Transform cam_0;
    public Transform cam_1;
    public Transform cam_2;

    [Header("Light")]
    public Transform directionalLight;
    public Transform light_1;
    public Transform light_2;

    [Header("UI")]
    public Image barFill;
    public RectTransform carUI;
    public Text levelText;
    public Text coinEarnText;

    private void Awake()
    {
        MMVibrationManager.iOSInitializeHaptics();
        Application.targetFrameRate = 60;
        Instance = this;
        roadManager.GenerateRoad();
    }
    
    private void Start()
    {
        levelGame = PlayerPrefs.GetInt("levelGame");
        levelFixed = levelGame;
        if(levelFixed >= levelPrefab.Length)
        {
            levelFixed = Random.Range(0, levelPrefab.Length);
        }

        levelText.text = "Lv." + (levelGame +1);

        GenerateLevel();
    }

    private void Update()
    {
     if(Input.GetKeyDown(KeyCode.C)) main.CoinAnimation();
        if (Input.GetKeyDown(KeyCode.D)) PlayerPrefs.DeleteAll();

    }

    private void FixedUpdate()
    {
        
    }

    private void LateUpdate()
    {
        UpdateBarUI();
    }

    private void LevelUp()
    {
        levelGame++;
        levelFixed = levelGame;
        if (levelFixed >= levelPrefab.Length)
        {
            levelFixed = Random.Range(0, levelPrefab.Length);
        }

        PlayerPrefs.SetInt("levelGame", levelGame);
    }

    public void Complete()
    {
        if (isComplete) return;

        isComplete = true;
        StartCoroutine(C_Complete());
    }

    private IEnumerator C_Complete()
    {
        LevelUp();

        yield return null;
    }

    public void Fail()
    {
        if (isComplete) return;

        isComplete = true;
        StartCoroutine(C_Fail());
    }

    private IEnumerator C_Fail()
    {
        mainCamera.transform.DOShakePosition(0.2f, 2.0f);
        yield return new WaitForSeconds(2.0f);
        UIManager.Instance.Show_FailUI();
    }

    private void Refresh()
    {
        if (main != null) Destroy(main.gameObject);

        main = Instantiate(mainPrefab);
        human.SetActive(true);
        human.transform.position = new Vector3(8.75f, human.transform.position.y, human.transform.position.z);

        mainCamera.transform.localPosition = cam_1.transform.localPosition;
        mainCamera.transform.localRotation = cam_1.transform.localRotation;
        directionalLight.transform.rotation = light_1.localRotation;

        if (isGenerateMap)
        {
            generateCar.GenerateRoad();
        }
        else
        {
            int lvl = levelFixed;
            GameObject levelObject = Instantiate(levelPrefab[lvl]);
            Instantiate(mapPrefab[lvl]);
            curveMaps[lvl].SetActive(true);
        }

    }

    private void GenerateLevel()
    {
        Refresh();
    }

    public void StartGame()
    {
        StartCoroutine(C_StartGame());
    }

    private IEnumerator C_StartGame()
    {
        UIManager.Instance.Show_InGameUI();

        yield return new WaitForSeconds(0.2f);
        human.transform.GetComponent<Animator>().SetTrigger("_Idle");
        Vector3 taxiPosition = human.transform.position;
        taxiPosition.x = 6.5f;

        man.Active(manText[levelFixed]);
        human.transform.DOMove(taxiPosition, 0.8f);

        yield return new WaitForSeconds(0.3f);
        human.transform.DORotate(Vector3.zero, 0.4f);

        yield return new WaitForSeconds(0.4f);
        human.gameObject.SetActive(false);
        Vibration();


        mainCamera.transform.DOLocalMove(cam_0.transform.localPosition, 1.0f);
        mainCamera.transform.DOLocalRotateQuaternion(cam_0.transform.localRotation, 1.0f);

        isStart = true;
    }

    public void FinishAnimation()
    {
        StartCoroutine(C_FinishAnimation());
    }

    private IEnumerator C_FinishAnimation()
    {
        isComplete = true;
        LevelUp();

        mainCamera.transform.DOLocalMove(cam_2.transform.localPosition, 1.0f);
        mainCamera.transform.DOLocalRotateQuaternion(cam_2.transform.localRotation, 1.0f);
        directionalLight.transform.DOLocalRotateQuaternion(light_2.localRotation, 1.0f);
        main.CoinAnimation();

        finishTransform.gameObject.GetComponent<FinishPosition>().arrow.SetActive(false);

        yield return new WaitForSeconds(1.0f);



        human.transform.eulerAngles = new Vector3(0.0f, 90.0f, 0.0f);

        Vector3 taxiPos = human.transform.position;
        taxiPos.x = main.car1.transform.position.x;
        taxiPos.z = main.car1.transform.position.z;
        human.transform.position = taxiPos;

        Vibration();
        human.gameObject.SetActive(true);

        Vector3 tarpos = human.transform.position;
        tarpos.x += 2.0f;
        human.transform.DOMove(tarpos, 1.0f);
        UIManager.Instance.Firework();


        yield return new WaitForSeconds(0.8f);
        human.transform.DORotate(Vector3.up * -90, 0.5f);
        human.transform.GetComponent<Animator>().SetTrigger("_Bye");
        
        yield return new WaitForSeconds(1.5f);
        UIManager.Instance.ShowCompleteUI();

        int _c = Random.Range(90, 150);
        UIManager.Instance.Coin += _c;
        coinEarnText.text = _c.ToString();
    }

    

    public void UpdateBarUI()
    {
        float a = Main.Instance.currentPositionCar;
        float b = finishTransform.position.z;
        float c = a / b;
        barFill.fillAmount = c;

        Vector2 carUI_pos = carUI.anchoredPosition;
        carUI_pos.x = Mathf.Lerp(-230, 230, c);
        carUI.anchoredPosition = carUI_pos;
    }

    private bool isVibration;

    public void Vibration()
    {
        if (isVibration) return;

        MMVibrationManager.Haptic(HapticTypes.MediumImpact);
        StartCoroutine(C_Vibration());
    }

    private IEnumerator C_Vibration()
    {
        isVibration = true;
        yield return new WaitForSeconds(0.2f);
        isVibration = false;
    }
}