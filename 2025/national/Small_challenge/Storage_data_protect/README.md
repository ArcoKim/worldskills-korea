# Storage data protect
## 개요
Object Storage인 S3에 저장되는 데이터 보호를 위한 솔루션을 구성합니다. Region은 ap-northeast-2을 사용합니다.

## 과제 설명
### S3
민감한 데이터를 가지고 있는 파일들을 관리하기 위해 S3를 사용합니다. S3에는 /masked라는 prefix와 /incoming이라는 prefix를 생성합니다. 주어진 배포파일은 /incoming prefix에 전부 업로드하도록 합니다.
- S3 Bucket Name : wsc2025-sensitive-<임의의 4개의 영문>

### Macie
S3에 저장된 민감한 데이터를 검색하고 보호하기 위해 Amazon Macie를 사용합니다. Macie를 활용하여 배포 파일 내의 모든 민감한 정보를 정확히 감지할 수 있어야 하며, 감지 기준은 아래 표를 참고합니다. Job 생성 시 S3 버킷 내 masked 접두어(prefix)를 가진 객체들에 대해서만 민감한 데이터를 감지하도록 설정하고, Job은 한 번만 실행되도록 구성해야 합니다. 채점 시에는 생성해둔 Job을 복사하여 사용하며, 해당 Job이 정상적으로 동작하지 않을 경우 감점 등의 불이익이 발생할 수 있습니다.
- Job Name : wsc2025-sensor-job

### Lambda
민감한 데이터의 유출을 방지하기 위해 AWS Lambda를 사용하여 데이터를 마스킹합니다. Lambda 함수는 S3 버킷의 incoming 접두어(prefix)를 가진 경로에 파일이 업로드되면 자동으로 실행되어, 해당 파일의 민감한 정보를 마스킹한 후 masked 접두어를 가진 경로에 저장해야 합니다. 마스킹 방식에 대한 예시는 아래 표를 참고합니다.
- Lambda Name : wsc2025-masking-start

| 민감한 정보 유형 | 원본 예시 (Maice에서 감지되어야 함) | 마스킹 예시 (Maice에서 감지되지 않아야함) |
|------------------|-------------------------------------|-------------------------------------------|
| names | Crystal White | Crystal ***** |
| emails | davisjesus@example.org | d*********@example.org |
| phone_numbers | 010-7658-5153 | 010-7658-**** |
| ssns | 887-07-7325 | 887-07-**** |
| card_numbers | 4468-6779-7028-4776 | 4468-6779-7028-**** |
| uuids | 665ef2db-cd63-4086-81e9-661ccaf8dd20 | 665ef2db-cd63-4086-81e9-************ |

