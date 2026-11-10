/// Endereço do Spring.
///
/// O padrão é `localhost`, que no celular (ou emulador) só chega no seu
/// computador se a porta for "espelhada" pelo cabo/ADB. Rode uma vez, com o
/// aparelho conectado:
///
/// `adb reverse tcp:8080 tcp:8080`
///
/// Sem isso, `localhost` dentro do aparelho é o próprio aparelho, e o app
/// mostra "Sem conexão". Para usar outro endereço, passe no `flutter run`:
///
/// - emulador, sem o `adb reverse`: `--dart-define=API_BASE_URL=http://10.0.2.2:8080`
/// - celular na mesma rede Wi-Fi: `--dart-define=API_BASE_URL=http://192.168.0.10:8080`
abstract final class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
}
