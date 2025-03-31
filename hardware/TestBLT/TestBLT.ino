#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

// 보내게 될 테스트 HZ
char test[20] = "{ \"V1\":50 }";

#define SERVICE_UUID        "00001812-0000-1000-8000-00805F9B34FB"
#define CHARACTERISTIC_UUID "00002B05-0000-1000-8000-00805F9B34FB"

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
  Serial.println("Sending data...");
  pCharacteristic->setValue(test);
  pCharacteristic->notify();

  delay(2000); // 2초마다 전송
}
