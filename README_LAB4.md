# Лабораторна робота №4: Kubernetes (K8s) та Minikube

## Тема листа
`[Розгортання Веб] Лабораторна робота №4: Kubernetes та Minikube`

## Мета та завдання
**Мета:** ознайомлення з архітектурою Kubernetes, робота з локальним кластером Minikube та `kubectl` для розгортання, масштабування та оновлення вебзастосунків.

**Завдання:**
- Встановити та налаштувати Minikube.
- Дослідити стан кластера та вузлів.
- Розгорнути масштабований Deployment.
- Опублікувати застосунок через Service (NodePort).
- Виконати rolling update та rollback.
- Увімкнути аддони (metrics-server, dashboard).

## Етап 1: Ініціалізація кластера
Запуск:
```powershell
minikube start --cpus 2 --memory 4096
kubectl cluster-info
kubectl get nodes
```

## Етап 2: Deployment + масштабування
Створення Deployment (як у методичці):
```powershell
kubectl create deployment web-app --image=registry.k8s.io/e2e-test-images/agnhost:2.53 -- /agnhost netexec --http-port=8080
kubectl get deployments
kubectl get pods -o wide
```

Масштабування до 3 реплік:
```powershell
kubectl scale deployment web-app --replicas=3
kubectl get pods -o wide
```

## Етап 3: Service (NodePort) + доступ у Minikube
```powershell
kubectl expose deployment web-app --type=NodePort --port=8080
kubectl get svc
minikube service web-app --url
```

Перевірка відповіді (curl) — має бути видно hostname pod у відповіді `agnhost`:
```powershell
$url = (minikube service web-app --url)
curl $url
```

Альтернативне підтвердження hostname Pod (для звіту):
```powershell
kubectl get pods
kubectl exec -it <POD_NAME> -- hostname
```

## Етап 4: Rolling Update та Rollback
Оновлення образу:
```powershell
kubectl set image deployment/web-app agnhost=registry.k8s.io/e2e-test-images/agnhost:2.39
kubectl rollout status deployment/web-app
kubectl rollout history deployment/web-app
```

Відкат:
```powershell
kubectl rollout undo deployment/web-app
kubectl rollout status deployment/web-app
```

## Етап 5: Аддони та діагностика
Metrics Server:
```powershell
minikube addons enable metrics-server
kubectl top pods
```

Dashboard:
```powershell
minikube dashboard
```

## Що додати у звіт (скріни)
- `kubectl cluster-info` та `kubectl get nodes`
- `kubectl get pods -o wide` після масштабування (3 pods)
- `kubectl get svc` + результат звернення до сервісу (curl/браузер, де видно hostname pod) або `kubectl exec ... hostname`
- `minikube addons enable metrics-server` + `kubectl top pods`
- Вікно `minikube dashboard`

