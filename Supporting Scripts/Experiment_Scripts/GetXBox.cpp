#include "mex.hpp"
#include "mexAdapter.hpp"
#include "MatLabDataArray.hpp"
#include <Windows.h>
#include <Xinput.h>
#include <iostream>

using namespace matlab::data;
using matlab::mex::ArgumentList;

#pragma comment(lib, "Xinput.lib")

class MexFunction : public matlab::mex::Function {
public:
    void operator()(ArgumentList outputs, ArgumentList inputs) override {
        // Create an ArrayFactory object
       ArrayFactory factory;

        // Create a 1x1 struct array with the field names we need
        std::vector<std::string> fieldNames = {"A","B","X","Y",
                            "JoystickRX", "JoystickRY", "JoystickLX", "JoystickLY",
                            "JoystickRThumb", "JoystickLThumb",
                            "LMovement", "RMovement",
                            "DPadUp","DPadDown","DPadLeft", "DPadRight",
                            "RB", "RT", "LB", "LT", "Start", "AnyButton"};
        StructArray structArray = factory.createStructArray({ 1, 1 }, fieldNames);

        // Read Xbox controller state
        XINPUT_STATE state;
        DWORD result = XInputGetState(0, &state);
        bool is_connected = (result == ERROR_SUCCESS);

        // Create temporary values (ease of editing) to store our variables using ternary operators
        bool A = is_connected ? (state.Gamepad.wButtons & XINPUT_GAMEPAD_A) != 0 : false;
        bool B = is_connected ? (state.Gamepad.wButtons & XINPUT_GAMEPAD_B) != 0 : false;
        bool X = is_connected ? (state.Gamepad.wButtons & XINPUT_GAMEPAD_X) != 0 : false;
        bool Y = is_connected ? (state.Gamepad.wButtons & XINPUT_GAMEPAD_Y) != 0 : false;
        double JoystickRX = is_connected ? double(state.Gamepad.sThumbRX) / 32767  : 0;
        double JoystickRY = is_connected ? double(state.Gamepad.sThumbRY) / -32767 : 0;
        bool JoystickRThumb = is_connected ? (state.Gamepad.wButtons & XINPUT_GAMEPAD_RIGHT_THUMB) != 0 : false;
        double JoystickLX = is_connected ? double(state.Gamepad.sThumbLX) / 32767  : 0;
        double JoystickLY = is_connected ? double(state.Gamepad.sThumbLY) / -32767 : 0;
        bool JoystickLThumb = is_connected ? (state.Gamepad.wButtons & XINPUT_GAMEPAD_LEFT_THUMB) != 0 : false;
        bool DPadUp = is_connected    ? (state.Gamepad.wButtons & XINPUT_GAMEPAD_DPAD_UP)    != 0 : false;
        bool DPadDown = is_connected  ? (state.Gamepad.wButtons & XINPUT_GAMEPAD_DPAD_DOWN)  != 0 : false;
        bool DPadLeft = is_connected  ? (state.Gamepad.wButtons & XINPUT_GAMEPAD_DPAD_LEFT)  != 0 : false;
        bool DPadRight = is_connected ? (state.Gamepad.wButtons & XINPUT_GAMEPAD_DPAD_RIGHT) != 0 : false;
        bool RB = is_connected ? (state.Gamepad.wButtons & XINPUT_GAMEPAD_RIGHT_SHOULDER) != 0 : false;
        double RT = is_connected ? double(state.Gamepad.bRightTrigger)/255 : 0;
        bool LB = is_connected ? (state.Gamepad.wButtons & XINPUT_GAMEPAD_LEFT_SHOULDER) != 0 : false;
        double LT = is_connected ? double(state.Gamepad.bLeftTrigger)/255 : 0;
        bool Start = is_connected ? (state.Gamepad.wButtons & XINPUT_GAMEPAD_START) != 0 : false;
        bool AnyButton = A || B || X || Y || JoystickRThumb || JoystickLThumb || DPadUp || DPadDown ||
                         DPadLeft || DPadRight || RB || LB || RT > 0.5 || LT > 0.5 || Start;

        // Assign the values we got into the structArray that we created
        structArray[0]["A"] = factory.createScalar<bool>(A);
        structArray[0]["B"] = factory.createScalar<bool>(B);
        structArray[0]["X"] = factory.createScalar<bool>(X);
        structArray[0]["Y"] = factory.createScalar<bool>(Y);
        structArray[0]["JoystickRX"] = factory.createScalar<double>(JoystickRX);
        structArray[0]["JoystickRY"] = factory.createScalar<double>(JoystickRY);
        structArray[0]["JoystickRThumb"] = factory.createScalar<bool>(JoystickRThumb);
        structArray[0]["JoystickLX"] = factory.createScalar<double>(JoystickLX);
        structArray[0]["JoystickLY"] = factory.createScalar<double>(JoystickLY);
        structArray[0]["JoystickLThumb"] = factory.createScalar<bool>(JoystickLThumb);
        structArray[0]["RMovement"] = factory.createArray<double>({1,2}, {JoystickRX, JoystickRY});
        structArray[0]["LMovement"] = factory.createArray<double>({1,2}, {JoystickLX, JoystickLY});
        structArray[0]["DPadUp"] = factory.createScalar<bool>(DPadUp);
        structArray[0]["DPadDown"] = factory.createScalar<bool>(DPadDown);
        structArray[0]["DPadLeft"] = factory.createScalar<bool>(DPadLeft);
        structArray[0]["DPadRight"] = factory.createScalar<bool>(DPadRight);
        structArray[0]["RB"] = factory.createScalar<bool>(RB);
        structArray[0]["RT"] = factory.createScalar<double>(RT);
        structArray[0]["LB"] = factory.createScalar<bool>(LB);
        structArray[0]["LT"] = factory.createScalar<double>(LT);
        structArray[0]["Start"] = factory.createScalar<bool>(Start);
        structArray[0]["AnyButton"] = factory.createScalar<bool>(AnyButton);

        // Assign the struct array to the output argument
        outputs[0] = std::move(structArray);
    }
};