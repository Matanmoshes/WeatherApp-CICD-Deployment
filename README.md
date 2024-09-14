---

### **Project Overview**

In this project, I have designed and deployed a **Weather Application** using **Python Flask**, which fetches real-time weather data from the **OpenWeather API**. The application is containerized using **Docker** and deployed on **AWS ECS (Elastic Container Service)** with **Fargate** to handle the container orchestration. All infrastructure resources are provisioned using **Terraform**, ensuring a secure, scalable, and automated deployment process.

The application is accessible via the domain `WeatherApp.matan-moshe.online`, managed through **AWS Route 53**. Traffic is routed securely through an **Application Load Balancer (ALB)** with **HTTPS** enabled, secured by a **Let's Encrypt SSL certificate** that is uploaded to **AWS Certificate Manager (ACM)**. This ensures encrypted communication between users and the application.

---

### **CI/CD Flow**

The **CI/CD pipeline** for this project is automated using **GitHub Actions** to streamline the entire deployment process.

- **Continuous Integration (CI)**:
    - The pipeline is triggered with every code push to the repository, performing:
        - **Linting** with `flake8`.
        - **Unit tests** using `pytest` to ensure application integrity.
        - Builds a **Docker image** of the Flask application.
        - Pushes the Docker image to **Docker Hub**.

- **Continuous Deployment (CD)**:
    - After successful integration, the CD pipeline automatically provisions the infrastructure on AWS using **Terraform**:
        - Sets up a **VPC** with public subnets across multiple availability zones.
        - Provisions an **ALB** that handles incoming traffic and secures communication via **SSL**.
        - Deploys the application as an **ECS Cluster** using **Fargate**.
        - Manages DNS for `WeatherApp.matan-moshe.online` through **Route 53**, with a **CNAME** pointing to the ALB.

*Visual representation of the CI/CD architecture will be added here.*

---

### **AWS Infrastructure Provisioning with Terraform**

The infrastructure for this project is designed with security, scalability, and automation in mind, and is entirely provisioned via **Terraform**:

1. **VPC (Virtual Private Cloud)**:
    - A custom **VPC** is created with two public subnets across multiple availability zones to ensure high availability and redundancy.
    - The **Internet Gateway** and **Route Tables** are configured to route internet traffic to the **ALB**.

2. **Application Load Balancer (ALB)**:
    - The **ALB** listens on **port 80** (HTTP) and **port 443** (HTTPS).
    - **HTTPS** traffic is secured using a **Let's Encrypt SSL certificate**, uploaded to **AWS ACM** and attached to the ALB.
    - The ALB forwards requests to the ECS tasks running the Flask app on **port 5000**.

3. **ECS (Elastic Container Service)**:
    - The application runs in **AWS ECS** using **Fargate**, allowing for containerized deployments without managing infrastructure.
    - The Flask app is deployed as a service, and traffic is routed through the ALB to ECS tasks.

4. **Security by Design**:
    - **Security Groups** are implemented to enforce **least privilege access**. The ECS service security group only allows inbound traffic on **port 5000** from the ALB's security group, ensuring that the containerized application is only accessible via the ALB.
    - This network design minimizes exposure to the public internet, protecting the container cluster by controlling access at the **network level**.
    - **Data Encryption**: All data is encrypted in transit using the **SSL certificate** signed by **Let's Encrypt**, providing end-to-end security for users accessing the weather application.

5. **Route 53**:
    - The domain `matan-moshe.online` is managed in **AWS Route 53**.
    - A **CNAME** record points `WeatherApp.matan-moshe.online` to the ALB, allowing secure access to the application via HTTPS.

6. **Auto Scaling**:
    - The ECS service includes **Auto Scaling policies**, scaling in and out based on **CPU utilization** thresholds (50% for scaling out and 30% for scaling in), ensuring optimal resource usage.

*Here, I will include visual architecture diagrams to illustrate the AWS infrastructure.*

---

### **Requirements**

Before running the project, you will need:

- **AWS Account** with permissions to create resources such as ECS, ALB, VPC, Route 53, and ACM.
- **DockerHub Account** to store and manage the Docker image of the application.
- **GitHub Repository** with GitHub Actions configured for the CI/CD pipeline.
- **Terraform** installed on your local machine to manage infrastructure provisioning.
- **Python 3.12** and **pip** if you want to run the application locally.

---

### **How to Run the Project**

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-repository/CI_CD_Flask_Weather_App.git
   cd CI_CD_Flask_Weather_App
   ```

2. **Set Up Secrets in GitHub**:
   - Navigate to your repository's **Settings** > **Secrets and variables**.
   - Add the following secrets:

   | Secret Name               | Description                                      |
   |---------------------------|--------------------------------------------------|
   | `AWS_ACCESS_KEY_ID`        | Your AWS Access Key ID                           |
   | `AWS_SECRET_ACCESS_KEY`    | Your AWS Secret Access Key                       |
   | `OPENWEATHER_API_KEY`      | API Key from OpenWeather for fetching weather data|
   | `DOCKER_USERNAME`          | Your Docker Hub username                         |
   | `DOCKER_PASSWORD`          | Your Docker Hub password                         |

3. **Run the CI Pipeline**:
   - Push changes to the repository, which will trigger the CI pipeline.
   - The pipeline will:
     - Lint the code using `flake8`.
     - Run unit tests using `pytest`.
     - Build the Docker image and push it to Docker Hub.

4. **Provision AWS Infrastructure via Terraform**:
   - The CD pipeline will automatically provision the infrastructure using **Terraform**, including:
     - VPC, subnets, Internet Gateway, and security groups.
     - ALB with an SSL certificate for **HTTPS** traffic.
     - ECS Cluster and services running the Flask app.

5. **Access the Application**:
   - Once the deployment is complete, you can access the weather app at `https://WeatherApp.matan-moshe.online`.

---

### **Conclusion**

This project demonstrates my ability to design, deploy, and manage a secure cloud-based application using **AWS ECS** with **Fargate**. It showcases security by design, with a focus on limiting access to the container cluster using **security groups**, encrypting traffic with an **SSL certificate**, and automating infrastructure provisioning using **Terraform**. The CI/CD pipeline automates the integration and deployment process, ensuring that code changes are tested, built, and deployed seamlessly.

