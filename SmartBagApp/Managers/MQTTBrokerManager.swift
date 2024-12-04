import CocoaMQTT

protocol MQTTManagerDelegate: AnyObject {
    func didConnectAck()
    func didDisconnect()
    func receivedMessage(topic: String, message: String?)
}

class MQTTManager: ObservableObject {
    @Published var message: String = ""
    
    weak var delegate: MQTTManagerDelegate?

    private var mqttClient: CocoaMQTT

    init(clientID: String = "1234",
         host: String = "localhost",
         port: Int = 1883) {
        mqttClient = CocoaMQTT(clientID: "1234", host: "localhost", port: 1883)
    }

    private func setup() {
        mqttClient.didConnectAck = { [weak self] mqtt, ack in
            LoggerHelper.logger.log("Conectado com sucesso ao broker MQTT")
            self?.delegate?.didConnectAck()
//            mqtt.subscribe("seu/topico/aqui")
        }

        mqttClient.didReceiveMessage = { [weak self] mqtt, message, id in
            LoggerHelper.logger.log("Mensagem recebida no tópico \(message.topic): \(message)")
            self?.delegate?.receivedMessage(topic: message.topic, 
                                            message: message.string)
        }
        
        mqttClient.didDisconnect = { [weak self] mqtt, error in
            LoggerHelper.logger.log("Desconectado: erro \(error)")
            self?.delegate?.didDisconnect()
        }

        _  = mqttClient.connect()
    }

    func publishMessage(_ message: String, toTopic topic: String) {
        let mqttMessage = CocoaMQTTMessage(topic: topic, string: message)
        mqttClient.publish(mqttMessage)
    }

    func subscribe(topic: String) {
        mqttClient.subscribe(topic)
    }

    func disconnect() {
        mqttClient.disconnect()
    }

    func connect() {
        setup()
    }
}
