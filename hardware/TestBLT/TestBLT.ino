#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>

struct RGB {
    uint8_t r;
    uint8_t g;
    uint8_t b;
};

typedef struct SSVEP_data {
  uint8_t     func;
  uint8_t     sec;
  struct RGB  color;
}SSVEP_data;

SSVEP_data parse_data(const char* input) {
    SSVEP_data result;
    char color_str[7];  // RGB + null

    sscanf(input, "F:%2hhuS:%2hhuC:%6s", &result.func, &result.sec, color_str);

    // RGB
    char r_str[3] = { color_str[0], color_str[1], '\0' };
    char g_str[3] = { color_str[2], color_str[3], '\0' };
    char b_str[3] = { color_str[4], color_str[5], '\0' };

    result.color.r = (uint8_t)strtol(r_str, NULL, 16);
    result.color.g = (uint8_t)strtol(g_str, NULL, 16);
    result.color.b = (uint8_t)strtol(b_str, NULL, 16);

    return result;
}

class _Callback : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) override {
    String rxValue = pCharacteristic->getValue();
    if (rxValue.length() > 0) {
      Serial.print("Received from mobile: ");
      Serial.println(rxValue.c_str());
    }
  }
};

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
    BLECharacteristic::PROPERTY_READ |
    BLECharacteristic::PROPERTY_WRITE |
    BLECharacteristic::PROPERTY_WRITE_NR |
    BLECharacteristic::PROPERTY_NOTIFY
  );
// Write 필요없을거같은데 일단 넣고봄.
// FIXME: 통신 구현 테스트 끝나면 지우기
  pCharacteristic->addDescriptor(new BLE2902());

  pCharacteristic->setValue("Hello! From Medical Device!");
  pService->start();

  pCharacteristic->setCallbacks(new _Callback());


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

  // 10HZ, 2Sec, 0xFFFFFF
  String msgA = "F:10SS:02C:fa94ff";
  // 20HZ, 5Sec, 0x7A544C
  String msgB = "F:20SS:05C:94fffa";
  
  Serial.print("Sending data... ");
  Serial.print(count%2 ? "Notify A " : "Notify B "); 
  Serial.println(++count);

  pCharacteristic->setValue(count%2 ? msgA.c_str() : msgB.c_str());
  pCharacteristic->notify();

  delay(10000); // 10초마다
}