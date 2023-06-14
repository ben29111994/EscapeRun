using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SwipeControl : MonoBehaviour
{
    public static SwipeControl Instance;

    private void Awake()
    {
        Instance = (Instance == null) ? this : Instance;
    }

    public bool isHold;
    private Vector2 currentTouchPosition;
    private Vector2 lastTouchPosition;
    public Vector2 deltaTouchPosition;
    public Vector2 deltaTouchFixed;
    private bool isBegan;

    private void Update()
    {
        UpdateSwipe();
    }

    private void UpdateSwipe()
    {
        bool touchBegan = false;
        bool touchMoved = false;
        bool touchEnded = false;

   

#if UNITY_EDITOR
        touchBegan = Input.GetMouseButtonDown(0);
        touchMoved = Input.GetMouseButton(0);
        touchEnded = Input.GetMouseButtonUp(0);
#elif UNITY_IOS
        if(Input.touchCount > 0)
        {
            touchBegan = Input.touches[0].phase == TouchPhase.Began;
            touchMoved = Input.touches[0].phase == TouchPhase.Moved;
            touchEnded = Input.touches[0].phase == TouchPhase.Ended;
        }
#endif


        if (touchBegan)
        {
            isBegan = true;
            isHold = true;
            currentTouchPosition = lastTouchPosition = Input.mousePosition;
        }
        else if (touchMoved)
        {
            if(isBegan == false)
            {
                isBegan = true;
                isHold = true;
                currentTouchPosition = lastTouchPosition = Input.mousePosition;
            }

            currentTouchPosition = Input.mousePosition;
            deltaTouchPosition = currentTouchPosition - lastTouchPosition;
            lastTouchPosition = currentTouchPosition;
            deltaTouchFixed = deltaTouchPosition.normalized;

        }
        else if (touchEnded)
        {
            isHold = isBegan = false;
            currentTouchPosition = lastTouchPosition = deltaTouchPosition = deltaTouchFixed = Vector2.zero;
        }
    }
}
