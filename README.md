# UART Control Project

---

## 요약
**SR04 초음파 센서**, **DHT11 온습도 센서** 모듈의 데이터 시트의 분석 및 작동 이해 후 **UART 통신**을 활용하여 제어하는 프로젝트입니다.


---
## 목차
- [설계 목표](#설계-목표)
- [센서모듈 설명](#센서모듈-설명)
- [Architecture](#Architecture)
- [FSM](#FSM)
- [Simulation](#Simulation)
- [Trouble Shooting](#Trouble-Shooting)
- [결론 및 고찰](#결론-및-고찰)

---

## 설계 목표  
<img width="1614" height="615" alt="image" src="https://github.com/user-attachments/assets/07c8feab-0c69-4502-a5d9-9c497a90d86e" />

UART 통신을 기반으로 **RX FIFO**와 FSM을 활용하여 센서 데이터의 **다중 바이트 수신** 및 상태 처리를 수행하고, CU(Control Unit)를 통해 여러 센서를 **통합 제어**하는 시스템을 구현하는 것.

---

## 센서모듈 설명

### SR04 Sensor 
<img width="1524" height="755" alt="image" src="https://github.com/user-attachments/assets/65157768-93b8-4e1e-9fd4-852b9f7a651d" />

### Trigger 전송

MCU가 TRIG 핀에 최소 10µs의 TTL High 펄스 전송. (I)

### 초음파 송신

모듈은 40kHz의 초음파를 8-cycle(≈200µs) 정도 송신하고 주변에서 반사된 신호 대기. (II)

### Echo 펄스 측정

모듈의 ECHO 핀은 반사파가 돌아오는 동안 High 상태를 유지.

이 ECHO High 지속시간을 **1MHz tick(1µs 단위)** 로 카운트 (echo == 1일 때 카운트.) (III)

### 종료 및 결과 저장

ECHO가 Low로 떨어지면 카운트 종료. 카운트값을 distance_data로 저장하고 dist_done 플래그를 세팅. (IV)




### DHT11 Sensor
<img width="1219" height="270" alt="image" src="https://github.com/user-attachments/assets/a1fa5606-e698-4215-9eba-e97e3e3dbf17" />
<img width="956" height="507" alt="image" src="https://github.com/user-attachments/assets/b64d9fd8-b89f-4c40-bce6-d56d95cdcd5f" />

### IDLE 
풀업 상태로 유지되고 센서는 대기 상태로 대기.

### START 
MCU가 데이터선을 LOW로 18ms 유지한 후 HIGH로 전환.

### WAIT
30usec의 WAIT를 기다린 후 INPUT으로 전환.

### SYNC
약 80µs LOW, 이어서 약 80µs HIGH의 응답 신호를 보내 데이터의 Sync 값을 먼저 수신.

### DATA
- 센서는 총 40비트의 데이터를 전송.

- 각 비트는 먼저 약 50µs LOW를 보낸 후 HIGH 펄스의 길이로 0/1을 구분.(HIGH 약 26–28µs는 비트 0을, HIGH 약 70µs는 비트 1을 의미)

### STOP
전송이 끝나면 센서는 라인을 릴리즈하고 다시 풀업 상태로 복귀.

---

## Architecture  

### SR04 Sensor

<img width="1624" height="787" alt="image" src="https://github.com/user-attachments/assets/273bd410-cb9f-4a7e-95fc-3a390e5dee49" />

UART통신을 통해 START Trigger를 주면 SR04센서 내로 Trigger 신호가 들어가고 Echo신호를 받아 거리를 측정.



### DHT11 Sensor

<img width="1601" height="748" alt="image" src="https://github.com/user-attachments/assets/06c56acc-5c88-4509-83bb-20f9dcb32b5f" />

UART통신을 통해 START Trigger를 주면 DHT11 내로 신호가 들어가고 Inout으로 선언 된 포트를 통해 온습도 데이터를 측정.


### TOP Module
<img width="1780" height="662" alt="image" src="https://github.com/user-attachments/assets/b90c4708-4c43-4908-9c23-6b6e335282a8" />

전체 TOP Module에선 UART 부분을 바깥으로 빼 모든 모듈을 하나의 **UART Control Unit**에서 제어할 수 있도록 설계. 또한 **FIFO**의 활용으로 **Multi Byte 데이터**를 받을 수 있도록 설계.

---

## FSM

<img width="1128" height="694" alt="image" src="https://github.com/user-attachments/assets/d06b87fb-6dca-4b5e-9966-026b161cb3cc" />

**시간모드(시계, 스톱워치 기능)** 와 **센서모드(온습도 센서, 초음파 센서 기능)** 를 각 모드에 따라 상태를 나누고 **3Byte의 데이터** 가 UART를 통해 들어오면 Control Unit의 판단에 따라 각 모듈을 제어.

---


## Simulation  

<img width="1781" height="650" alt="image" src="https://github.com/user-attachments/assets/00726e63-a47f-4b18-a9e1-fd89d759529d" />

<img width="1782" height="662" alt="image" src="https://github.com/user-attachments/assets/0b698115-0a05-43a8-9150-4d0b5e8d2b09" />

<img width="1781" height="668" alt="image" src="https://github.com/user-attachments/assets/a15d9f7c-0ce9-485d-a845-f2827fee15fc" />

<img width="1784" height="662" alt="image" src="https://github.com/user-attachments/assets/fac6743c-eff4-43d9-8d64-4680e982d8bc" />

---

## Trouble Shooting  

<img width="1560" height="672" alt="image" src="https://github.com/user-attachments/assets/22baadc1-335b-4d57-8ffd-5e12cd5953dc" />


<img width="1744" height="698" alt="image" src="https://github.com/user-attachments/assets/527a819d-40e1-4aee-a3a2-2f35d2b3d774" />


---

## 결론 및 고찰

**결론**
- 각 모듈의 **데이터시트의 분석**을 통해 모듈 설계를 성공적으로 해냈음.
- 모든 모듈들을 **UART의 Multi Byte 통신**과 **Control Unit**을 통해 성공적으로 제어하였음.

**느낀점**
- 모듈을 설계하는 과정에서 **데이터시트의 정밀한 분석**과 **타이밍 제어**가 중요함을 느꼈음.
- 그로 인해 어떤 새로운 모듈을 다루더라도 데이터시트만 있다면 제어가 가능함을 깨달았음.
- 또한 TX, RX의 **UART 통신 구조**와 **FIFO**를 같이 다루면서 전반적인 통신 프로토콜을 이해함.

**아쉬운점**
- 설계를 3Byte만 받을 수 있도록 설계하여 3Byte가 아닌 데이터가 들어오면 값이 꼬이는 현상이 있었음.
- 한 단어가 끝났다는 어떠한 신호가 있다면 이를 해결할 수 있을 것임.
