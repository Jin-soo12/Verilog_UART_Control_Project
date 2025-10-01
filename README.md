# UART Control Project

---

## 📝요약
SR04 초음파 센서, DHT11 온습도 센서 모듈의 데이터 시트의 분석 및 작동 이해 후 UART 통신을 활용하여 제어하는 프로젝트입니다.


---
## 📚목차
- [설계 목표](#설계-목표)
- [센서모듈 설명](#센서모듈-설명)
- [Architecture](#Architecture)
- [주요코드 설명](#주요코드-설명)
- [Simulation](#Simulation)
- [Trouble Shooting](#Trouble-Shooting)
- [결론 및 고찰](#결론-및-고찰)

---

## 설계 목표  
<img width="1614" height="615" alt="image" src="https://github.com/user-attachments/assets/07c8feab-0c69-4502-a5d9-9c497a90d86e" />

UART 통신을 기반으로 **RX FIFO**와 FSM을 활용하여 센서 데이터의 **다중 바이트 수신** 및 상태 처리를 수행하고, CU(Control Unit)를 통해 여러 센서를 **통합 제어**하는 시스템을 구현하는 것이 목표입니다.

---

## 센서모듈 설명

### SR04 Sensor
<img width="1524" height="755" alt="image" src="https://github.com/user-attachments/assets/65157768-93b8-4e1e-9fd4-852b9f7a651d" />

### Trigger 전송

MCU가 TRIG 핀에 최소 10µs의 TTL High 펄스를 보낸다. (I)

### 초음파 송신

모듈은 40kHz의 초음파를 8-cycle(≈200µs) 정도 송신하고 주변에서 반사된 신호를 기다린다. (II)

### Echo 펄스 측정

모듈의 ECHO 핀은 반사파가 돌아오는 동안 High 상태를 유지한다.

이 ECHO High 지속시간을 **1MHz tick(1µs 단위)** 로 카운트한다 (echo == 1일 때 카운트.) (III)

### 종료 및 결과 저장

ECHO가 Low로 떨어지면 카운트 종료. 카운트값을 distance_data로 저장하고 dist_done 플래그를 세팅한다. (IV)

---

### DHT11 Sensor
<img width="1219" height="270" alt="image" src="https://github.com/user-attachments/assets/a1fa5606-e698-4215-9eba-e97e3e3dbf17" />
<img width="956" height="507" alt="image" src="https://github.com/user-attachments/assets/b64d9fd8-b89f-4c40-bce6-d56d95cdcd5f" />

### IDLE 
버스는 풀업 상태로 유지되고 센서는 대기 상태로 대기한다.

### START 
MCU가 데이터선을 LOW로 ≥18ms 유지한 후 HIGH로 전환한다.

### WAIT
30usec의 WAIT를 기다린 후 INPUT으로 전환한다.

### SYNC
약 80µs LOW, 이어서 약 80µs HIGH의 응답 신호를 보내 데이터의 Sync 값을 먼저 받는다.

### DATA 전송 
- 센서는 총 40비트의 데이터를 전송한다.

- 각 비트는 먼저 약 50µs LOW를 보낸 후 HIGH 펄스의 길이로 0/1을 구분한다.(HIGH 약 26–28µs는 비트 0을, HIGH 약 70µs는 비트 1을 의미)

### STOP / 완료 
전송이 끝나면 센서는 라인을 릴리즈하고 버스는 다시 풀업 상태로 복귀한다.

---

## Architecture  

---

## 주요코드 설명  

---

## Simulation  

---

## Trouble Shooting  

---

