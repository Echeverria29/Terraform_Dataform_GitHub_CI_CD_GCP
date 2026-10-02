```
🚀 Modern Data Platform en GCP: Terraform + Dataform + GitOps CI/CD
```

Este repositorio implementa una plataforma de datos moderna en Google Cloud Platform (GCP) basada en la Arquitectura Medallion (Bronze, Silver, Gold). Utiliza un enfoque GitOps desacoplando la gestión de infraestructura base vía Terraform del modelado y transformación analítica vía Dataform.

## 🏗️️ Arquitectura y Flujo GitOps

### 1. Separación de Responsabilidades

* **Terraform (Infraestructura IaaS):** Provisiona la estructura base en GCP: Datasets de BigQuery (`bronze_retail`, `silver_retail`, `gold_retail`), Buckets de GCS, Service Accounts y esquemas raw iniciales.

* **Dataform (Transformaciones / Data Engineering):** Administra el ciclo de vida de las tablas analíticas dentro de BigQuery. Realiza la limpieza, estandarización, cargas incrementales y pruebas de calidad de datos (`assertions`).

```
graph TD
    subgraph Terraform [Infraestructura]
        A[(bronze_retail)]
        B[(silver_retail)]
        C[(gold_retail)]
    end

    subgraph Dataform [Transformaciones SQLX]
        A -->|Modelos Incrementales| B
        B -->|Agregaciones BI| C
    end

```

### 2. Flujo de Integración Continua (CI/CD)

```
graph TD
    Dev[Developer Push / PR] --> Actions[GitHub Actions CI]
    
    Actions -->|terraform.yml| TF[Terraform Validate & Plan]
    Actions -->|dataform.yml| DF[Dataform Compile Check]
    
    TF -->|Push a Main| Apply[Terraform Apply - GCP]
    DF -->|Push a Main| GCPDF[GCP Dataform Service - Execution]

```

* **`terraform.yml`:** Ejecuta `validate` y `plan` en ramas secundarias/PRs, y aplica los cambios (`apply`) únicamente en la rama `main`.

* **`dataform.yml`:** Instala el CLI de Dataform y valida en memoria la sintaxis de los modelos `.sqlx` y sus dependencias (`dataform compile`).

## 📂 Estructura del Monorepo

```
.
├── .github/
│   └── workflows/
│       ├── dataform.yml            # Pipeline CI: Validación y compilación SQLX
│       └── terraform.yml           # Pipeline CI/CD: Validación y despliegue de Infraestructura
├── dataform/
│   ├── definitions/
│   │   ├── bronze/                 # Declaraciones de tablas base / fuentes
│   │   └── silver/                 # Transformaciones incrementales (.sqlx)
│   └── workflow_settings.yaml      # Configuración de entornos y compilación en GCP/Local
├── IAC/
│   ├── environment/
│   │   └── dev/
│   │       └── env.tfvars.json     # Variables locales de entorno (¡Debes llenarlo para pruebas locales!)
│   ├── modules/
│   │   ├── bigquery_dataset/       # Módulo para creación de datasets (Bronze, Silver, Gold)
│   │   └── bigquery_table/         # Módulo para tablas base
│   ├── main.tf                     # Orquestador principal de Terraform
│   ├── provider.tf                 # Configuración de proveedores GCP
│   ├── variables.tf                # Variables globales
│   └── outputs.tf                  # Salidas del despliegue
├── LICENSE.md
└── README.md

```

## 🔑 Configuración de Secretos en GitHub

Para autorizar a GitHub Actions a interactuar con GCP de forma segura, debes configurar los siguientes parámetros en tu repositorio (**Settings -> Secrets and variables -> Actions**):

* **Service Account Key (Secret):**

  * **Nombre:** `KEYGCP`

  * **Valor:** El contenido de tu archivo JSON de credenciales de GCP codificado en Base64.

  * **Comandos para codificar:**

    * **Linux / WSL:** `base64 -w 0 key.json`

    * **macOS:** `base64 -i key.json | tr -d '\n'`

    * **PowerShell:** `[Convert]::ToBase64String([IO.File]::ReadAllBytes("key.json"))`

* **Variables de Repositorio (Variables - Opcional si usas el método por defecto con GitHub Variables):**

  * `GCP_PROJECT`, `GCP_REGION`, `BUCKET_NAME`, `ENVIRONMENT`, `PROVIDER`.

## 🛠️ Requisitos e Instalación Local (Para Pruebas y Desarrollo)

Antes de hacer un push a GitHub, se recomienda configurar tu entorno local (en Ubuntu / WSL / Linux) instalando las herramientas necesarias:

### 1. Instalar Google Cloud CLI (`gcloud`)

```
# Agregar la distribución de gcloud y sus llaves oficiales
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates gnupg curl
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt-get update && sudo apt-get install -y google-cloud-cli

```

### 2. Instalar Terraform

```
# Descargar e instalar la herramienta de HashiCorp Terraform
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform

```

### 3. Instalar Node.js, npm y Dataform CLI

```
# Limpiar lista obsoleta de apt si fuera necesario e instalar Node.js
sudo rm -f /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt update && sudo apt install -y nodejs npm
sudo npm install -g @dataform/cli

```

## ⚙️ Modelos de Ejecución: Local vs. GitHub Actions

### Opción A: Pruebas Locales (Llenando el archivo `env.tfvars.json`)

Para hacer pruebas locales en tu máquina, primero debes rellenar manualmente el archivo de variables estático ubicado en `IAC/environment/dev/env.tfvars.json`:

```
{
  "labels": {
    "provider": "tu-proveedor-local"
  },
  "project": "tu-proyecto-gcp",
  "region": "us-central1",
  "bucket_name": "tu-bucket-local"
}

```

Luego, autentícate localmente con GCP y ejecuta los comandos:

```
# Autenticación con tu cuenta o service account local
gcloud auth application-default login

# Ejecutar Terraform local
cd IAC
terraform init
terraform plan -var-file="environment/dev/env.tfvars.json"

# Compilar Dataform local
cd ../dataform
npx @dataform/cli compile

```

### Opción B: Producción / CI-CD por defecto (Usando Variables de GitHub Actions)

Por defecto, el archivo `terraform.yml` está configurado para no requerir archivos de variables estáticos en el repositorio. En su lugar, el pipeline toma las Variables del Repositorio de GitHub y genera el archivo `env.tfvars.json` dinámicamente "al vuelo" justo antes de ejecutar el plan.

Así es como debe lucir el bloque principal por defecto en tu archivo `terraform.yml`:

```
      # MÉTODO POR DEFECTO EN GITHUB ACTIONS: Genera el archivo .tfvars.json al vuelo 
      # usando las Variables de GitHub para evitar exponer datos sensibles en el repositorio público.
      - name: Generate Secure tfvars file
        run: |
          cat << EOF > environment/${{ vars.ENVIRONMENT }}/env.tfvars.json
          {
            "labels": {
              "provider": "${{ vars.PROVIDER }}"
            },
            "project": "${{ vars.GCP_PROJECT }}",
            "region": "${{ vars.GCP_REGION }}",
            "bucket_name": "${{ vars.BUCKET_NAME }}"
          }
          EOF
      - name: Terraform Init & Plan
        run: |
          terraform init
          terraform plan -var-file="environment/${{ vars.ENVIRONMENT }}/env.tfvars.json" -out=tfplan
        env:
          GOOGLE_CREDENTIALS: key.json

```

### 🔄 Alternativa en `terraform.yml` (Si quisieras probar el despliegue automático usando tu archivo local estático)

Si en algún momento prefieres que el pipeline de GitHub Actions ignore las variables de la plataforma y lea directamente tu archivo físico `env.tfvars.json` guardado en el repositorio (cuidando de no subir secretos duros), puedes reemplazar el bloque anterior por este:

```
      # ALTERNATIVA LOCAL (Para referencia / Comentado si prefieres usar el archivo estático del repo):
      - name: Terraform Init & Plan (Local tfvars)
        run: |
          terraform init
          terraform plan -var-file="environment/${{ vars.ENVIRONMENT }}/env.tfvars.json" -out=tfplan
        env:
          GOOGLE_CREDENTIALS: key.json

```

### 🔄 Despliegue de prueba local (Guardar estado del despliegue terraform)

Si necesitas realizar pruebas en tu máquina local y no deseas usar el backend remoto en Google Cloud Storage, elimina o comenta el siguiente bloque de código en `provider.tf`. Esto hará que Terraform guarde el estado localmente (`terraform.tfstate`):

```
      backend "gcs" {
        bucket = "dataflow-staging-us-east1-761179275057"
        prefix = "terraform/state/dev"
      }

```

## 🔄 Conexión con GCP Dataform Console

Para programar la ejecución en producción de tus transformaciones analíticas:

1. Dirígete a **BigQuery -> Dataform** en la consola de Google Cloud.

2. Crea y conecta un repositorio vinculado a este repositorio de GitHub mediante un Personal Access Token (PAT).

3. Configura el **Root directory** apuntando a la carpeta `dataform`.

4. Crea una **Release Configuration** vinculada a la rama `main`.

5. Define una **Workflow Configuration** estableciendo la periodicidad de ejecución (Cron) para correr los modelos incrementales y sus validaciones de calidad.

## 🔐 Configuración de Permisos IAM y Ejecución en Dataform Console

Para garantizar que Dataform compile los grafos, ejecute los modelos incrementales SQLX y cree el dataset automático `dataform_assertions` sin errores de permisos (`403 Access Denied` o `BigQuery Job User missing`), es imprescindible configurar los roles IAM correctos.

### 1. Cuentas de Servicio Involucradas

* **Service Agent por Defecto de Dataform:**
  Creado automáticamente por GCP al habilitar la API de Dataform.

  *Formato:* `service-PROJECT_NUMBER@gcp-sa-dataform.iam.gserviceaccount.com`

* **Service Account Personalizada (Ejecución/Workflows):**
  Cuenta de servicio dedicada para la ejecución de pipelines de datos (ejemplo: `pub-sub-data-flow@...`).

### 2. Roles IAM Requeridos

Ambas cuentas de servicio deben contar con los siguientes roles asignados en IAM a nivel de proyecto:

* 🔹 **BigQuery Data Editor** (`roles/bigquery.dataEditor`): Permite la creación y actualización de tablas en los datasets `bronze_retail`, `silver_retail`, `gold_retail` y la creación implícita del dataset `dataform_assertions`.

* 🔹 **BigQuery Job User** (`roles/bigquery.jobUser`): Permite ejecutar jobs de consulta y transformación SQL dentro de BigQuery.

* 🔹 **Secret Manager Secret Accessor** (`roles/secretmanager.secretAccessor`): Permite a Dataform leer los tokens de autenticación (PAT) almacenados en GCP Secret Manager para conectarse al repositorio remoto de GitHub.

* 🔹 **Service Account Token Creator** (`roles/iam.serviceAccountTokenCreator`): Permite realizar la suplantación de identidad (*impersonation*) de la Service Account asignada durante la ejecución de los flujos.

### 3. Ejecución Manual y Selección de Service Account

Al iniciar una ejecución desde la interfaz de Dataform (**Development Workspaces -> Start execution**):

1. Selecciona la opción **Execute with selected service account**.

2. Elige en la lista desplegable la Service Account autorizada (`pub-sub-data-flow@...`).

3. Haz clic en **Start execution**.

Esto garantiza que las transformaciones se ejecuten bajo la identidad y los permisos adecuados, asegurando la trazabilidad y la correcta generación de los esquemas en BigQuery.