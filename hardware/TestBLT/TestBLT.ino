#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

// 보내게 될 메시지 블록
struct msgblk
{
  short hz = 0;
  short sec = 0;
  char color[7] = "";
}msg;

// 보내게 될 테스트 정보
char* TEST_sendMSG(){
  if( msg.hz > 60 )
    {
      msg.hz = 0;
      msg.sec = 0;
    }
  else
  {
    msg.hz += 1;
    msg.sec += 1;
  }
}

#define SERVICE_UUID        "e2c56db5-dffb-48d2-b060-d0f5a71096e0"
#define CHARACTERISTIC_UUID "a495ff10-c5b1-4b44-b512-1370f02d74de"

BLECharacteristic *pCharacteristic;

void setup()
{
  Serial.begin(115200);
    BLEDevice::init("SSVEP-Device");
  BLEServer *pServer = BLEDevice::createServer();
  BLEService *pService = pServer->createService(SERVICE_UUID);
// 
  pCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID, 
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE | BLECharacteristic::PROPERTY_NOTIFY
  );
// Write 필요없을거같은데 일단 넣고봄.
// FIXME: 통신 구현 테스트 끝나면 지우기

  pCharacteristic->setValue("Hello! From Medical Device!");
  pService->start();

  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
  Serial.println("Characteristic defined! Now you can read it in your mobile!");

}

void loop()
{
  static int count = 0;

  Serial.print("Sending data... ");
  Serial.println(++count);
  
  String msg = "MSG by BLE count, " + String(count);
  pCharacteristic->setValue(msg.c_str());
  pCharacteristic->notify();

  delay(1000); // 2초마다 전송
}
