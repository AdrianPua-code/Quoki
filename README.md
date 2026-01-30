# Gestor de Gastos Quoki (App Móvil)

Una aplicación moderna y visualmente atractiva para gestionar tus finanzas personales, desarrollada en Flutter.

## Características Principales

*   **Gestión de Balance**: Realiza un seguimiento en tiempo real de tu dinero disponible con la fórmula: `(Ingreso Base + Extras) - (Gastos Pagados + Ahorros)`.
*   **Historial Mensual**: Accede a un resumen detallado de cada mes con ingresos, gastos, ahorros y porcentaje de ahorro. Visualiza tu progreso financiero a lo largo del tiempo.
*   **Onboarding Inteligente**: Para nuevos usuarios, la app te guía paso a paso para configurar tu perfil financiero completo: ingresos mensuales, gastos principales, deudas con cuotas y metas de ahorro.
*   **Gestión de Deudas con Cuotas**: Crea deudas con planes de pago en cuotas mensuales. Define número de cuotas y monto a pagar. Realiza abonos extra y monitorea tu progreso de pago.
*   **Control Detallado de Deudas**: Visualiza el estado de cada deuda (cuotas pagadas/total), haz pagos regulares, abonos extra y modifica el plan de cuotas cuando lo necesites.
*   **Diseño Moderno**: Interfaz moderna inspirada en aplicaciones como Duolingo y Airbnb, con colores vibrantes, tarjetas limpias y tipografía amigable (Nunito).
*   **Control de Gastos**: Agrega transacciones recurrentes o únicas. Marca gastos como "pagados" para descontarlos de tu balance.
    *   Para deudas: Configura planes de cuotas con montos personalizados y gestiona pagos individuales.
*   **Metas de Ahorro**: Crea objetivos de ahorro (ej. "Vacaciones"), visualiza tu progreso con barras dinámicas y recibe felicitaciones al cumplirlos.
*   **Ingresos Flexibles**: Define un ingreso mensual base y añade ingresos extra cuando sea necesario.
*   **Persistencia de Datos**: Todo se guarda localmente en tu dispositivo, sin necesidad de internet.

## Tecnologías

*   **Flutter**: Framework UI multiplataforma.
*   **Provider**: Gestión de estado.
*   **Shared Preferences**: Almacenamiento local de datos.
*   **Google Fonts**: Tipografía personalizada (Nunito).
*   **Intl**: Formateo de moneda y fechas.

## Cómo Iniciar

1.  **Clonar el repositorio** (si ya lo has subido):
    ```bash
    git clone <tu-repositorio-url>
    ```
2.  **Instalar dependencias**:
    ```bash
    flutter pub get
    ```
3.  **Ejecutar la App**:
    ```bash
    flutter run
    ```

## Flujo de Onboarding para Nuevos Usuarios

La primera vez que abras la app, pasarás por un asistente de configuración de 5 pasos:

1.  **Bienvenida**: Presentación de la app y sus características principales
2.  **Ingresos**: Configura tu ingreso mensual base
3.  **Gastos**: Agrega tus gastos recurrentes mensuales (alquiler, servicios, etc.)
4.  **Deudas**: Registra tus deudas actuales con opción de planes de cuotas
5.  **Ahorros**: Define tus metas de ahorro personal

Al finalizar, tendrás tu perfil financiero completamente configurado y listo para usar.

## Estructura del Proyecto

*   `lib/`: Código fuente de la aplicación (Dart).
    *   `providers/`: Lógica de negocio y estado (`FinanceProvider`).
    *   `screens/`: Pantallas de la app (`HomeScreen`, `SavingsScreen`, `MonthlySummaryScreen`, `DebtDetailScreen`, etc.).
    *   `theme/`: Configuración de diseño y estilos (`AppTheme`).
    *   `widgets/`: Componentes reutilizables (`SummaryCard`).
    *   `models/`: Estructura de datos (`Transaction`, `Saving`, `MonthlySummary`, `DebtPayment`).
*   `test/`: Pruebas unitarias y de widgets.

---
*Desarrollado por adrian samudio pua para ayudarte a ahorrar.*
