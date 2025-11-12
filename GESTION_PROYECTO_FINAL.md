# GESTIÓN DE PROYECTO - MUNANI APP V2
## Sistema E-commerce de Barritas Nutritivas - Offline-First

---

## 1. SPIDER DE CARACTERÍSTICAS PRINCIPALES DEL ENFOQUE DEL PROYECTO

```
                    Metodología Ágil (Scrum)
                            ⭐⭐⭐⭐⭐
                                |
                                |
    Escalabilidad ⭐⭐⭐⭐——————————————————⭐⭐⭐⭐⭐ Arquitectura Limpia
         ⭐⭐⭐                                    (Clean Architecture)
           |                                            |
           |                                            |
    Seguridad                                    Offline-First
    (OWASP) ⭐⭐⭐⭐⭐                              ⭐⭐⭐⭐⭐
           |                                            |
           |                                            |
    Mantenibilidad                              Rendimiento
       ⭐⭐⭐⭐⭐————————————————————————————————⭐⭐⭐⭐⭐
                                |
                                |
                        Experiencia de Usuario
                            ⭐⭐⭐⭐⭐
```

### Descripción de Características:

| Característica | Nivel | Justificación |
|----------------|-------|---------------|
| **Metodología Ágil** | ⭐⭐⭐⭐⭐ | Sprints de 2 semanas, entrega incremental, retrospectivas continuas |
| **Arquitectura Limpia** | ⭐⭐⭐⭐⭐ | Clean Architecture con separación en capas (Domain, Data, Presentation) |
| **Offline-First** | ⭐⭐⭐⭐⭐ | Funciona 100% sin conexión, sincronización automática bidireccional |
| **Rendimiento** | ⭐⭐⭐⭐⭐ | Base de datos Isar de alto rendimiento, respuestas instantáneas |
| **UX** | ⭐⭐⭐⭐⭐ | Material 3, interfaz intuitiva, feedback inmediato al usuario |
| **Mantenibilidad** | ⭐⭐⭐⭐⭐ | Código modular, principios SOLID, documentación completa |
| **Seguridad** | ⭐⭐⭐⭐⭐ | OWASP Top 10, rate limiting, validaciones, logging de seguridad |
| **Escalabilidad** | ⭐⭐⭐⭐ | Soporta múltiples tiendas/almacenes, sincronización eficiente |

---

## 2. CICLO DE VIDA DEL PROYECTO

### 2.1. INICIO - Definir Objetivo y Alcance

#### 🎯 Objetivo del Proyecto
Desarrollar una aplicación móvil empresarial de e-commerce para la comercialización de barritas nutritivas "Munani", con capacidad offline-first que permita gestionar inventario, ventas, compras, transferencias y pedidos de clientes en múltiples ubicaciones (tiendas y almacenes), garantizando sincronización automática bidireccional con el servidor cuando haya conexión a internet.

#### 📋 Alcance del Proyecto

**Incluye:**
- ✅ Sistema de autenticación con 4 roles (Admin, Gerente Tienda, Gerente Almacén, Cliente)
- ✅ Gestión completa de productos y variantes
- ✅ Control de inventario multi-ubicación con alertas
- ✅ Sistema de transferencias entre ubicaciones con aprobación
- ✅ Gestión de compras a proveedores
- ✅ Registro de ventas con ajuste automático de inventario
- ✅ Carrito de compras para clientes con revisión de pedidos
- ✅ Sistema de reportes analíticos (ventas, compras, transferencias)
- ✅ Sincronización offline-first bidireccional
- ✅ Base de datos local (Isar) y remota (Supabase)
- ✅ Seguridad implementada según OWASP Top 10
- ✅ Aplicación móvil multiplataforma (Android/iOS)

**No Incluye:**
- ❌ Sistema de facturación electrónica (SIN - Bolivia)
- ❌ Integración con pasarelas de pago automáticas
- ❌ Sistema de delivery tracking en tiempo real
- ❌ Aplicación web (solo móvil)
- ❌ Sistema de notificaciones push
- ❌ Chat en tiempo real
- ❌ Geolocalización de entregas

#### 👥 Actores Involucrados (Stakeholders)

| Rol | Nombre | Responsabilidades | Tiempo Dedicación |
|-----|--------|-------------------|-------------------|
| **Sponsor** | Danae Revollo | • Proveer financiamiento<br>• Aprobar presupuesto<br>• Validar entregables<br>• Definir prioridades de negocio<br>• Tomar decisiones estratégicas | 10% (Reuniones semanales) |
| **Project Manager / Team Lead** | David | • Planificación del proyecto<br>• Gestión de equipo y recursos<br>• Seguimiento de cronograma<br>• Gestión de riesgos<br>• Comunicación con sponsor<br>• Desarrollo backend y sincronización<br>• Arquitectura del sistema | 100% (Full-time) |
| **Developer Full-Stack** | Jonas | • Desarrollo frontend (UI/UX)<br>• Implementación de features<br>• Testing de componentes<br>• Documentación técnica<br>• Code reviews | 100% (Full-time) |
| **Developer Full-Stack** | Daniel | • Desarrollo backend (API)<br>• Base de datos (Supabase)<br>• Seguridad (OWASP)<br>• Integración y deployment<br>• Code reviews | 100% (Full-time) |

#### 🎯 Objetivos SMART del Proyecto

| Objetivo | SMART |
|----------|-------|
| **S**pecific | Desarrollar app móvil e-commerce offline-first para Munani con 13 módulos funcionales |
| **M**easurable | • 13 features completas<br>• 100% funcionalidad offline<br>• <2s tiempo de respuesta<br>• 95% cobertura de tests críticos<br>• 0 vulnerabilidades OWASP críticas |
| **A**chievable | Equipo de 3 desarrolladores experimentados, stack tecnológico probado (Flutter, Supabase, Isar) |
| **R**elevant | Soluciona problema real de gestión multi-ubicación sin depender de internet permanente |
| **T**ime-bound | 16 semanas (4 meses) dividido en 8 sprints de 2 semanas cada uno |

---

### 2.2. PLANIFICACIÓN - Cronograma, Fases, Presupuestos, Recursos

#### 📅 Cronograma General (16 Semanas - 8 Sprints)

```
Mes 1 (Semanas 1-4): Fundamentos y Core
├── Sprint 1 (Sem 1-2): Setup + Auth + Core
│   ├── Configuración del proyecto
│   ├── CI/CD pipeline
│   ├── Arquitectura base
│   ├── Sistema de autenticación
│   └── Base de datos local/remota
│
└── Sprint 2 (Sem 3-4): Products + Locations
    ├── CRUD de productos y variantes
    ├── Gestión de tiendas y almacenes
    ├── Sistema de permisos por rol
    └── UI básica

Mes 2 (Semanas 5-8): Inventario y Operaciones
├── Sprint 3 (Sem 5-6): Inventory + Transfers
│   ├── Control de inventario multi-ubicación
│   ├── Alertas de stock
│   ├── Sistema de transferencias
│   └── Workflow de aprobación
│
└── Sprint 4 (Sem 7-8): Purchases + Suppliers
    ├── Gestión de proveedores
    ├── Compras con items
    ├── Recepción de compras
    └── Ajuste automático de inventario

Mes 3 (Semanas 9-12): Ventas y Clientes
├── Sprint 5 (Sem 9-10): Sales + Customers
│   ├── Registro de ventas
│   ├── Gestión de clientes
│   ├── Integración con inventario
│   └── Numeración automática
│
└── Sprint 6 (Sem 11-12): Cart + Orders
    ├── Carrito de compras cliente
    ├── Upload de comprobantes
    ├── Revisión de pedidos por gerentes
    └── Workflow completo de pedidos

Mes 4 (Semanas 13-16): Reportes y Finalización
├── Sprint 7 (Sem 13-14): Reports + Polish
│   ├── Reportes de ventas/compras/transferencias
│   ├── Gráficos y visualizaciones
│   ├── Optimización de performance
│   └── Refinamiento de UI/UX
│
└── Sprint 8 (Sem 15-16): Testing + Deploy
    ├── Testing integral (E2E)
    ├── Corrección de bugs críticos
    ├── Documentación final
    ├── Capacitación de usuarios
    └── Deployment a producción
```

#### 🗓️ Calendario de Sprints

| Sprint | Semanas | Inicio | Fin | Entregable Principal |
|--------|---------|--------|-----|----------------------|
| Sprint 1 | 1-2 | 2025-09-19 | 2025-10-02 | Sistema de autenticación + Core funcional |
| Sprint 2 | 3-4 | 2025-10-03 | 2025-10-16 | CRUD Productos + Locations |
| Sprint 3 | 5-6 | 2025-10-17 | 2025-10-30 | Inventario + Transferencias |
| Sprint 4 | 7-8 | 2025-10-31 | 2025-11-13 | Compras + Proveedores |
| Sprint 5 | 9-10 | 2025-11-14 | 2025-11-27 | Ventas + Clientes |
| Sprint 6 | 11-12 | 2025-11-28 | 2025-12-11 | Carrito + Sistema de Pedidos |
| Sprint 7 | 13-14 | 2025-12-12 | 2025-12-25 | Reportes + Optimización |
| Sprint 8 | 15-16 | 2025-12-26 | 2026-01-08 | Testing + Deploy |

#### 💰 Presupuesto del Proyecto

##### 1. Recursos Humanos

| Rol | Tarifa/Hora | Horas/Semana | Semanas | Costo Total |
|-----|-------------|--------------|---------|-------------|
| **Project Manager / Team Lead** (David) | $25/hora | 40 horas | 16 semanas | **$16,000** |
| **Developer Full-Stack** (Jonas) | $20/hora | 40 horas | 16 semanas | **$12,800** |
| **Developer Full-Stack** (Daniel) | $20/hora | 40 horas | 16 semanas | **$12,800** |
| **SUBTOTAL RRHH** | | | | **$41,600** |

*Nota: Tarifas basadas en promedio de mercado para desarrolladores Flutter/Full-Stack en Latinoamérica*

##### 2. Infraestructura y Servicios Cloud

| Servicio | Plan | Costo Mensual | Meses | Costo Total |
|----------|------|---------------|-------|-------------|
| **Supabase** (Pro Plan) | • 8 GB Database<br>• 100 GB Bandwidth<br>• 100 GB Storage<br>• Auth ilimitado<br>• 500K Monthly Active Users | $25/mes | 4 meses | **$100** |
| **Google Play Store** | Registro desarrollador (pago único) | - | - | **$25** |
| **Apple App Store** | Registro desarrollador (anual) | - | - | **$99** |
| **Firebase** (Spark - Free) | • Crashlytics<br>• Analytics<br>• Performance Monitoring | $0/mes | 4 meses | **$0** |
| **GitHub** (Free) | Repositorio privado + CI/CD | $0/mes | 4 meses | **$0** |
| **Dominio Web** (Opcional) | munaniapp.com | $12/año | - | **$12** |
| **SUBTOTAL INFRAESTRUCTURA** | | | | **$236** |

##### 3. Herramientas y Software

| Herramienta | Costo | Propósito |
|-------------|-------|-----------|
| **Flutter SDK** | Gratis | Framework de desarrollo |
| **Android Studio** | Gratis | IDE para Android |
| **Xcode** | Gratis | IDE para iOS (requiere Mac) |
| **VS Code** | Gratis | Editor de código |
| **Figma** (Free) | Gratis | Diseño UI/UX |
| **Postman** (Free) | Gratis | Testing de API |
| **SUBTOTAL HERRAMIENTAS** | **$0** | - |

##### 4. Contingencia y Otros

| Concepto | Monto | Justificación |
|----------|-------|---------------|
| **Contingencia** (10%) | $4,184 | Imprevistos, bugs críticos, cambios de alcance |
| **Capacitación usuarios** | $500 | 2 sesiones de capacitación (2h c/u) |
| **SUBTOTAL CONTINGENCIA** | **$4,684** | - |

#### 💵 RESUMEN DE PRESUPUESTO

| Categoría | Costo |
|-----------|-------|
| 💼 Recursos Humanos | **$41,600** |
| ☁️ Infraestructura y Servicios | **$236** |
| 🛠️ Herramientas y Software | **$0** |
| 🔧 Contingencia y Otros | **$4,684** |
| **COSTO TOTAL DEL PROYECTO** | **$46,520** |

#### 📊 Desglose de Costos por Fase

| Fase | % del Proyecto | Costo |
|------|----------------|-------|
| Inicio (Sprint 1) | 12.5% | $5,815 |
| Planificación y Core (Sprint 2) | 12.5% | $5,815 |
| Inventario (Sprints 3-4) | 25% | $11,630 |
| Ventas y Clientes (Sprints 5-6) | 25% | $11,630 |
| Reportes y Cierre (Sprints 7-8) | 25% | $11,630 |

#### 🎯 Propuesta de Valor para el Sponsor

##### ROI (Return of Investment) Estimado:

**Costos actuales (sin sistema):**
- Pérdida por falta de control de inventario: $2,000/mes
- Tiempo perdido en conteo manual: $1,500/mes
- Errores en transferencias: $800/mes
- **Total mensual actual: $4,300**

**Ahorro proyectado con Munani App:**
- Reducción de pérdidas: $1,800/mes (90%)
- Ahorro en tiempo: $1,350/mes (90%)
- Reducción de errores: $700/mes (87.5%)
- **Total ahorro mensual: $3,850**

**ROI:**
- Inversión: $46,520
- Ahorro anual: $46,200 ($3,850 × 12 meses)
- **Recuperación de inversión: 12 meses**
- **ROI a 3 años: 197%** (beneficio de $91,680)

#### 🎯 Precio de Venta Sugerido del Software

##### Modelo de Licenciamiento Propuesto:

**Opción 1: Licencia Perpetua**
- Pago único: **$55,000 - $65,000**
- Incluye: Código fuente, instalación, capacitación
- Mantenimiento: $500/mes (actualizaciones, soporte)

**Opción 2: Licencia por Suscripción (SaaS)**
- Setup inicial: **$15,000**
- Suscripción mensual: **$1,200/mes** por ubicación
- Incluye: Hosting, mantenimiento, soporte, actualizaciones

**Opción 3: Licencia Híbrida (Recomendada)**
- Pago inicial: **$35,000**
- Suscripción mensual: **$800/mes**
- Incluye: Todo lo anterior + nuevas features trimestrales

##### Comparación de Mercado:

| Competidor | Precio | Características |
|------------|--------|-----------------|
| **Sistema POS Tradicional** | $3,000 - $10,000 | Sin offline, una ubicación |
| **Odoo ERP** | $20/usuario/mes | Requiere internet permanente |
| **SAP Business One** | $50,000 - $200,000 | Sobrecargado, complejo |
| **Munani App** | $35,000 + $800/mes | Offline-first, multi-ubicación, móvil |

**Ventaja competitiva:** 40% más económico que competidores con funcionalidad offline completa.

#### 📦 Recursos del Proyecto

##### Recursos Técnicos:
- 🖥️ 3 laptops de desarrollo (existentes)
- 📱 2 dispositivos Android de prueba (existentes)
- 📱 1 dispositivo iOS de prueba (existente)
- ☁️ Cuenta Supabase Pro
- 📊 Herramientas de gestión: Trello/Jira (Free)

##### Recursos de Conocimiento:
- 📚 Documentación Flutter oficial
- 📚 Documentación Supabase
- 📚 Clean Architecture guidelines
- 📚 OWASP Security guidelines

---

### 2.3. EJECUCIÓN - Desarrollo del Producto/Código

#### 🏗️ Metodología de Desarrollo: Scrum

##### Ceremonias Scrum:

| Ceremonia | Frecuencia | Duración | Participantes | Objetivo |
|-----------|------------|----------|---------------|----------|
| **Daily Stand-up** | Diaria (Lun-Vie) | 15 min | Todo el equipo | Sincronización diaria, identificar bloqueos |
| **Sprint Planning** | Inicio de sprint | 2 horas | Todo el equipo + Sponsor | Definir objetivo y backlog del sprint |
| **Sprint Review** | Fin de sprint | 1 hora | Todo el equipo + Sponsor | Demo de entregables, feedback |
| **Sprint Retrospective** | Fin de sprint | 1 hora | Equipo desarrollo | Mejora continua del proceso |
| **Backlog Refinement** | Mitad de sprint | 1 hora | Todo el equipo | Refinar historias de usuario futuras |

##### Product Backlog Inicial (Épicas Principales):

```
🎯 ÉPICA 1: Autenticación y Seguridad
├── US-001: Login con email/password
├── US-002: Recuperación de contraseña
├── US-003: Gestión de sesiones
├── US-004: Rate limiting
└── US-005: Roles y permisos

🎯 ÉPICA 2: Gestión de Productos
├── US-006: CRUD de productos
├── US-007: Gestión de variantes
├── US-008: Upload de imágenes
├── US-009: Categorización
└── US-010: Búsqueda y filtros

🎯 ÉPICA 3: Control de Inventario
├── US-011: Ver inventario por ubicación
├── US-012: Ajustar cantidades
├── US-013: Alertas de stock bajo
├── US-014: Historial de movimientos
└── US-015: Reportes de inventario

🎯 ÉPICA 4: Transferencias
├── US-016: Solicitar transferencia
├── US-017: Aprobar/Rechazar transferencia
├── US-018: Ejecutar transferencia
├── US-019: Historial de transferencias
└── US-020: Notificaciones de estado

🎯 ÉPICA 5: Compras
├── US-021: Gestión de proveedores
├── US-022: Crear orden de compra
├── US-023: Recibir compra
├── US-024: Ajuste automático de inventario
└── US-025: Historial de compras

🎯 ÉPICA 6: Ventas
├── US-026: Registrar venta
├── US-027: Gestión de clientes
├── US-028: Ajuste automático de inventario
├── US-029: Historial de ventas
└── US-030: Ticket de venta

🎯 ÉPICA 7: Carrito de Compras
├── US-031: Agregar productos al carrito
├── US-032: Upload de comprobante
├── US-033: Revisión por gerente
├── US-034: Aprobación de pedido
└── US-035: Historial de pedidos

🎯 ÉPICA 8: Reportes
├── US-036: Reporte de ventas diarias
├── US-037: Reporte de ventas por periodo
├── US-038: Reporte de compras
├── US-039: Reporte de transferencias
└── US-040: Dashboard analítico

🎯 ÉPICA 9: Sincronización Offline
├── US-041: Funcionalidad offline completa
├── US-042: Cola de sincronización
├── US-043: Resolución de conflictos
├── US-044: Indicador de estado de sync
└── US-045: Sync automático en background
```

##### Definition of Done (DoD):

✅ **Una historia de usuario está "Done" cuando:**
1. Código escrito siguiendo Clean Architecture
2. Unit tests implementados (mínimo 80% cobertura)
3. Integration tests para flujos críticos
4. Code review aprobado por al menos 1 desarrollador
5. Documentación técnica actualizada
6. UI/UX revisada y aprobada
7. Funciona offline (si aplica)
8. Sin vulnerabilidades de seguridad críticas
9. Merged a branch `develop`
10. Demo exitoso al Sponsor

##### Estrategia de Branching (Git Flow):

```
main (producción)
  ↑
  └── develop (integración)
        ↑
        ├── feature/auth-login (features)
        ├── feature/products-crud
        ├── bugfix/inventory-sync (bugfixes)
        └── hotfix/critical-bug (hotfixes)
```

##### Convenciones de Commits:

```bash
feat: Agregar autenticación con biometría
fix: Corregir sincronización de inventario
docs: Actualizar README con instrucciones de deploy
refactor: Reestructurar servicio de sincronización
test: Agregar tests para módulo de compras
style: Aplicar formato según linting rules
perf: Optimizar queries de Isar
chore: Actualizar dependencias de Flutter
```

#### 🔨 Stack Tecnológico de Desarrollo:

```
Frontend (Mobile):
├── Flutter 3.5.0+
├── Dart 3.0+
└── Material 3

Gestión de Estado:
├── flutter_bloc 8.1.6+
├── equatable 2.0.5+
└── bloc 8.1.4+

Base de Datos Local:
├── isar 3.1.0+
├── isar_flutter_libs 3.1.0+
└── path_provider 2.1.4+

Backend:
├── Supabase Flutter 2.5.11+
└── PostgreSQL 15+ (Supabase)

Network:
├── dio 5.7.0+
├── connectivity_plus 6.0.5+
└── internet_connection_checker_plus 2.5.2+

Utilidades:
├── get_it 8.0.0+ (DI)
├── dartz 0.10.1+ (Either)
├── uuid 4.5.0+
├── intl 0.19.0+
└── logger 2.4.0+

Testing:
├── flutter_test
├── mocktail 1.0.4+
└── integration_test

CI/CD:
├── GitHub Actions
└── Firebase App Distribution (opcional)
```

---

### 2.4. MONITOREO Y CONTROL - Seguimiento de Avances y Riesgos

#### 📊 Métricas de Seguimiento

##### 1. Métricas de Progreso (Burndown Chart)

```
Story Points por Sprint:
Sprint 1: 40 puntos
Sprint 2: 45 puntos
Sprint 3: 50 puntos
Sprint 4: 45 puntos
Sprint 5: 50 puntos
Sprint 6: 45 puntos
Sprint 7: 40 puntos
Sprint 8: 35 puntos

Total: 350 Story Points
```

##### 2. Métricas de Calidad

| Métrica | Objetivo | Medición |
|---------|----------|----------|
| **Code Coverage** | ≥80% | Semanal |
| **Bugs Críticos** | 0 en producción | Diaria |
| **Velocidad del Equipo** | 40-50 SP/sprint | Por sprint |
| **Tiempo de Respuesta App** | <2 segundos | Semanal |
| **Vulnerabilidades Seguridad** | 0 críticas, 0 altas | Por sprint |
| **Tech Debt** | <15% del tiempo | Mensual |

##### 3. KPIs del Proyecto

| KPI | Fórmula | Target | Frecuencia |
|-----|---------|--------|------------|
| **% Completitud** | (Story Points Done / Total SP) × 100 | 100% al final | Semanal |
| **Variación Presupuesto** | (Costo Real - Costo Planeado) / Costo Planeado | ±10% | Quincenal |
| **Variación Cronograma** | (Tiempo Real - Tiempo Planeado) / Tiempo Planeado | ±5% | Semanal |
| **Satisfacción Sponsor** | Encuesta 1-10 | ≥8 | Por sprint |
| **Bugs por Feature** | Bugs encontrados / Features entregadas | ≤3 | Por sprint |

#### 🚨 Gestión de Riesgos

##### Matriz de Riesgos Identificados:

| ID | Riesgo | Probabilidad | Impacto | Severidad | Mitigación | Contingencia |
|----|--------|--------------|---------|-----------|------------|--------------|
| **R01** | Retrasos en desarrollo por complejidad técnica | Media (40%) | Alto | 🔴 **Alta** | • Pair programming<br>• Spike de investigación<br>• Refinamiento continuo | • Reducir alcance no crítico<br>• Extender 1 sprint |
| **R02** | Conflictos de sincronización offline compleja | Media (30%) | Alto | 🟠 **Media-Alta** | • Strategy de last-write-wins<br>• Timestamps consistentes<br>• Testing exhaustivo | • Implementar resolución manual<br>• Logs detallados |
| **R03** | Cambios de alcance por sponsor | Media (35%) | Medio | 🟠 **Media** | • Reuniones semanales<br>• Backlog priorizado<br>• Definition of Done clara | • Agregar sprint adicional<br>• Cobro de change orders |
| **R04** | Problemas de performance en dispositivos viejos | Baja (20%) | Medio | 🟡 **Baja-Media** | • Testing en dispositivos reales<br>• Optimización continua<br>• Lazy loading | • Definir requisitos mínimos<br>• Modo light |
| **R05** | Pérdida de desarrollador clave | Baja (15%) | Alto | 🟠 **Media** | • Documentación continua<br>• Code reviews<br>• Pair programming | • Contratar reemplazo urgente<br>• Redistribuir tareas |
| **R06** | Vulnerabilidades de seguridad descubiertas | Media (25%) | Alto | 🟠 **Media-Alta** | • OWASP guidelines<br>• Security reviews<br>• Penetration testing | • Hotfix inmediato<br>• Parche de seguridad |
| **R07** | Problemas con servicios de Supabase | Baja (10%) | Alto | 🟡 **Baja-Media** | • Plan Pro con SLA<br>• Monitoreo 24/7<br>• Backup automático | • Failover a Supabase self-hosted<br>• Migrar a Firebase |
| **R08** | Rechazo de app stores (Play/App Store) | Baja (15%) | Medio | 🟡 **Baja** | • Seguir guidelines estrictas<br>• Pre-review de políticas | • Corrección y resubmit<br>• Distribución enterprise |

##### Plan de Respuesta a Riesgos:

**Estrategias:**
1. **Evitar**: Cambiar plan para eliminar riesgo
2. **Mitigar**: Reducir probabilidad o impacto
3. **Transferir**: Pasar riesgo a terceros (seguro, proveedor)
4. **Aceptar**: Asumir el riesgo y preparar contingencia

#### 📈 Reportes de Avance

##### Reporte Semanal al Sponsor:

**Formato de Email:**
```
Asunto: 📊 Munani App - Reporte Semana #X

Hola Danae,

Resumen semanal del proyecto Munani App:

✅ COMPLETADO ESTA SEMANA:
• [Lista de historias de usuario completadas]
• [Métricas de progreso]

🔨 EN PROGRESO:
• [Lista de tareas actuales]

⏭️ PRÓXIMA SEMANA:
• [Lista de tareas planeadas]

🚨 BLOQUEOS/RIESGOS:
• [Ninguno / Descripción de bloqueos]

📊 MÉTRICAS:
• Progreso: XX% completado
• Presupuesto: $XX gastado de $XX (XX%)
• Cronograma: En tiempo / X días de retraso

📹 DEMO: [Link a video de demo si aplica]

Saludos,
David - Project Manager
```

##### Dashboard de Proyecto (Actualización Diaria):

```
📊 MUNANI APP - DASHBOARD

🎯 Progreso General: ████████████░░░░░░░░ 60% (210/350 SP)

📅 Sprint Actual: Sprint 5 - Ventas y Clientes
   └─ Progreso Sprint: ████████████████░░░░ 80% (40/50 SP)

⏱️ Cronograma:
   ├─ Inicio: 2025-09-19
   ├─ Hoy: 2025-11-12 (Semana 8 de 16)
   └─ Fin Estimado: 2026-01-08

💰 Presupuesto:
   ├─ Total: $46,520
   ├─ Gastado: $28,912 (62%)
   └─ Restante: $17,608

✅ Quality Gates:
   ├─ Code Coverage: 84% ✅
   ├─ Bugs Críticos: 0 ✅
   ├─ Vulnerabilidades: 0 ✅
   └─ Performance: <2s ✅

🚨 Riesgos Activos: 2 (1 media, 1 baja)
```

---

### 2.5. CIERRE - Entrega, Documentación, Lecciones Aprendidas

#### 📦 Entregables del Proyecto

##### 1. Entregables de Software:

| # | Entregable | Descripción | Formato |
|---|------------|-------------|---------|
| 1 | **Aplicación Móvil Compilada** | • APK firmado para Android<br>• IPA firmado para iOS | .apk, .ipa |
| 2 | **Código Fuente** | • Repositorio Git completo<br>• Historial de commits<br>• Branches organizados | Git repository |
| 3 | **Base de Datos** | • Schema de Supabase (PostgreSQL)<br>• RLS policies configuradas<br>• Datos de prueba | .sql |
| 4 | **Assets y Recursos** | • Imágenes, iconos<br>• Logos en diferentes resoluciones | .png, .svg |

##### 2. Entregables de Documentación:

| # | Documento | Contenido | Audiencia |
|---|-----------|-----------|-----------|
| 1 | **Manual de Usuario** | • Guía paso a paso por rol<br>• Screenshots de cada pantalla<br>• Casos de uso comunes<br>• FAQs | Usuarios finales |
| 2 | **Manual Técnico** | • Arquitectura del sistema<br>• Diagramas de clases/secuencia<br>• API documentation<br>• Decisiones de diseño | Desarrolladores |
| 3 | **Guía de Instalación** | • Requisitos de sistema<br>• Pasos de instalación<br>• Configuración inicial<br>• Troubleshooting | IT/Admin |
| 4 | **Guía de Deployment** | • CI/CD pipeline<br>• Configuración de servers<br>• Variables de entorno<br>• Rollback procedures | DevOps |
| 5 | **Plan de Mantenimiento** | • Schedule de backups<br>• Actualizaciones de seguridad<br>• Monitoreo de performance<br>• SLA acordados | Sponsor/IT |

##### 3. Capacitación de Usuarios:

| Sesión | Audiencia | Duración | Contenido |
|--------|-----------|----------|-----------|
| **Sesión 1** | Administradores | 2 horas | • Gestión de usuarios y permisos<br>• Configuración de productos<br>• Monitoreo de operaciones<br>• Reportes analíticos |
| **Sesión 2** | Gerentes (Tienda/Almacén) | 2 horas | • Control de inventario<br>• Transferencias<br>• Compras y proveedores<br>• Revisión de pedidos |
| **Sesión 3** | Vendedores | 1.5 horas | • Registro de ventas<br>• Gestión de clientes<br>• Consulta de inventario |
| **Sesión 4** | Clientes (Opcional) | 30 min | • Navegación de catálogo<br>• Carrito de compras<br>• Upload de comprobantes |

##### 4. Material de Capacitación:

- 📹 Videos tutoriales (1 por módulo, ~5 min c/u)
- 📄 Quick Reference Cards (PDF, 1 página por rol)
- 🎓 Quiz de evaluación post-capacitación
- 💬 Canal de Slack/WhatsApp para soporte continuo

#### ✅ Criterios de Aceptación Final

**El proyecto se considera completado cuando:**

| # | Criterio | Verificación |
|---|----------|--------------|
| 1 | Todas las 40 historias de usuario implementadas y probadas | ✅ Sprint Review final |
| 2 | 0 bugs críticos, <5 bugs menores | ✅ Testing report |
| 3 | Code coverage ≥80% | ✅ SonarQube report |
| 4 | Performance <2s en todas las operaciones | ✅ Performance testing |
| 5 | Funcionalidad offline 100% operativa | ✅ Offline testing |
| 6 | Aprobación del Sponsor en demo final | ✅ Sign-off document |
| 7 | Apps publicadas en Play Store y App Store | ✅ Store links |
| 8 | Documentación completa entregada | ✅ Documentation checklist |
| 9 | Capacitación realizada con asistencia >90% | ✅ Attendance sheets |
| 10 | Servidor de producción en operación | ✅ Uptime monitoring |

#### 📋 Checklist de Cierre

```
🔲 PRE-CIERRE (Semana 15)
  ├─ ☑️ Todas las features implementadas
  ├─ ☑️ Testing integral completado
  ├─ ☑️ Code freeze (solo bugfixes críticos)
  ├─ ☑️ Documentación técnica finalizada
  └─ ☑️ Demo final preparada

🔲 ENTREGA (Semana 16)
  ├─ ☑️ Apps compiladas y firmadas
  ├─ ☑️ Código fuente entregado
  ├─ ☑️ Servidor de producción configurado
  ├─ ☑️ Backups automáticos configurados
  ├─ ☑️ Certificados SSL instalados
  └─ ☑️ Monitoreo activo

🔲 CAPACITACIÓN (Semana 16)
  ├─ ☑️ Sesión 1: Administradores
  ├─ ☑️ Sesión 2: Gerentes
  ├─ ☑️ Sesión 3: Vendedores
  ├─ ☑️ Material de capacitación entregado
  └─ ☑️ Evaluaciones completadas

🔲 DOCUMENTACIÓN (Semana 16)
  ├─ ☑️ Manual de Usuario
  ├─ ☑️ Manual Técnico
  ├─ ☑️ Guía de Instalación
  ├─ ☑️ Guía de Deployment
  └─ ☑️ Plan de Mantenimiento

🔲 ADMINISTRATIVO
  ├─ ☑️ Facturación final
  ├─ ☑️ Sign-off del Sponsor
  ├─ ☑️ Cierre de contratos
  ├─ ☑️ Lecciones aprendidas documentadas
  └─ ☑️ Celebración de cierre 🎉
```

#### 🎓 Retrospectiva Final y Lecciones Aprendidas

##### Template de Retrospectiva:

```
🎯 RETROSPECTIVA FINAL - MUNANI APP V2

📅 Fecha: [Fecha de cierre]
👥 Participantes: David, Jonas, Daniel

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ ¿QUÉ FUNCIONÓ BIEN? (Keep Doing)

• [Ejemplo: Clean Architecture facilitó testing y mantenimiento]
• [Ejemplo: Daily stand-ups mantuvieron al equipo sincronizado]
• [Ejemplo: Offline-first fue decisión acertada para el contexto]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️ ¿QUÉ PUDO SER MEJOR? (Improve)

• [Ejemplo: Estimaciones iniciales muy optimistas]
• [Ejemplo: Necesitamos más testing en dispositivos físicos]
• [Ejemplo: Documentación en tiempo real vs. al final]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 ¿QUÉ HAREMOS DIFERENTE? (Start Doing)

• [Ejemplo: Implementar code reviews obligatorios desde día 1]
• [Ejemplo: Spike de investigación para features complejas]
• [Ejemplo: Testing de performance semanal]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🛑 ¿QUÉ DEJAREMOS DE HACER? (Stop Doing)

• [Ejemplo: Dejar documentación para el final]
• [Ejemplo: Subestimar complejidad de sincronización offline]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 MÉTRICAS FINALES

• Story Points planificados: 350 SP
• Story Points entregados: [Actual]
• Velocidad promedio: [XX] SP/sprint
• Presupuesto: $[Actual] de $46,520
• Cronograma: [En tiempo / +X días]
• Bugs en producción: [Cantidad]
• Satisfacción del Sponsor: [X/10]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🏆 LOGROS DESTACADOS

• [Ejemplo: 0 vulnerabilidades de seguridad críticas]
• [Ejemplo: 100% funcionalidad offline lograda]
• [Ejemplo: Sistema de sincronización robusto]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 LECCIONES CLAVE PARA PRÓXIMOS PROYECTOS

1. [Lección técnica]
2. [Lección de proceso]
3. [Lección de comunicación]
4. [Lección de gestión]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 ACCIONES DE SEGUIMIENTO

| Acción | Responsable | Fecha Límite |
|--------|-------------|--------------|
| [Acción 1] | [Nombre] | [Fecha] |
| [Acción 2] | [Nombre] | [Fecha] |

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

#### 🎉 Ceremonia de Cierre

**Agenda de Reunión de Cierre:**

1. **Presentación de Resultados** (15 min)
   - Métricas finales
   - Comparación plan vs. real
   - Logros destacados

2. **Demo Final Completa** (30 min)
   - Walkthrough de todas las features
   - Casos de uso reales
   - Performance showcase

3. **Entrega de Documentación** (10 min)
   - Revisión de entregables
   - Firma de documentos de aceptación

4. **Retrospectiva de Equipo** (20 min)
   - Compartir lecciones aprendidas
   - Celebración de logros

5. **Plan de Soporte Post-Lanzamiento** (10 min)
   - SLA acordados
   - Canales de soporte
   - Próximos pasos

6. **Reconocimiento y Celebración** (15 min)
   - Agradecimientos
   - Feedback del Sponsor
   - Brindis virtual/presencial 🥂

---

## 3. TRIÁNGULO DE HIERRO (Restricción Triple)

```
                        🎯 CALIDAD
                   (NUNCA NEGOCIABLE)
                           /\
                          /  \
                         /    \
                        /      \
                       /        \
                      /          \
                     /   ÁMBITO   \
                    /   DEL PROYECTO \
                   /                  \
                  /____________________\
               ⏱️ TIEMPO            💰 COSTO
```

### 📐 Definición del Triángulo de Hierro

**Fórmula:** `TIEMPO + COSTO + ALCANCE = CALIDAD`

> **Principio Fundamental:** La CALIDAD nunca es negociable.
> Cualquier cambio en uno de los tres lados (Tiempo, Costo, Alcance)
> afectará a los otros dos, pero la CALIDAD debe mantenerse constante.

---

### 🔺 Análisis de Cada Vértice

#### 1️⃣ ⏱️ TIEMPO (Cronograma)

**Definición:** El tiempo total requerido para completar el proyecto.

**Para Munani App:**
- **Tiempo Total:** 16 semanas (4 meses)
- **Sprints:** 8 sprints de 2 semanas cada uno
- **Hitos Clave:**
  - Semana 2: Auth funcional
  - Semana 8: Módulos core completos
  - Semana 12: Sistema de pedidos operativo
  - Semana 16: Lanzamiento a producción

**Variables que afectan el Tiempo:**
- ✅ Tamaño y experiencia del equipo (3 desarrolladores senior)
- ✅ Complejidad técnica (Clean Architecture + Offline-first)
- ⚠️ Cambios de alcance durante el proyecto
- ⚠️ Bugs críticos no anticipados
- ⚠️ Dependencias externas (app stores, terceros)

**Impacto de cambios:**
```
Si TIEMPO ↓ (se reduce):
  → COSTO ↑ (más desarrolladores u horas extra)
  → ALCANCE ↓ (reducir features)
  → CALIDAD = (mantener estándares)

Si TIEMPO ↑ (se extiende):
  → COSTO ↑ (más meses de salarios)
  → ALCANCE ↑ (más features posibles)
  → CALIDAD = (mantener estándares)
```

---

#### 2️⃣ 💰 COSTO (Presupuesto)

**Definición:** Los recursos financieros totales asignados al proyecto.

**Para Munani App:**
- **Presupuesto Total:** $46,520
- **Desglose:**
  - RRHH: $41,600 (89.4%)
  - Infraestructura: $236 (0.5%)
  - Contingencia: $4,684 (10.1%)

**Componentes del Costo:**
- 💼 **Costo Directo:** Salarios de desarrolladores ($41,600)
- ☁️ **Costo Infraestructura:** Supabase, stores, dominio ($236)
- 🔧 **Costo Indirecto:** Capacitación, soporte ($500)
- 🚨 **Reserva de Contingencia:** 10% del total ($4,184)

**Impacto de cambios:**
```
Si COSTO ↓ (se reduce):
  → TIEMPO ↑ (menos recursos = más lento)
  → ALCANCE ↓ (menos features)
  → CALIDAD = (mantener estándares, priorizar)

Si COSTO ↑ (se aumenta):
  → TIEMPO ↓ (más recursos = más rápido)
  → ALCANCE ↑ (más features posibles)
  → CALIDAD = (mantener estándares)
```

**Optimización de Costos sin afectar Calidad:**
- ✅ Usar herramientas open-source (Flutter, VS Code)
- ✅ Plan Pro de Supabase ($25/mes) vs. Enterprise ($599/mes)
- ✅ Firebase gratuito para analytics
- ✅ GitHub Actions gratis para CI/CD
- ✅ Capacitación interna vs. consultores externos

---

#### 3️⃣ 📏 ALCANCE (Scope)

**Definición:** La suma total de entregables, features y funcionalidades del proyecto.

**Para Munani App:**
- **Módulos:** 13 features completos
- **Historias de Usuario:** 40 user stories (350 story points)
- **Entregables:** Apps móviles (Android/iOS), backend, documentación

**Alcance Detallado:**

**✅ INCLUIDO (In-Scope):**
```
1. Autenticación (5 US, 40 SP)
   └─ Login, recuperación, roles, seguridad

2. Productos (5 US, 45 SP)
   └─ CRUD productos, variantes, imágenes

3. Inventario (5 US, 50 SP)
   └─ Control multi-ubicación, alertas

4. Transferencias (5 US, 45 SP)
   └─ Solicitud, aprobación, ejecución

5. Compras (5 US, 45 SP)
   └─ Proveedores, órdenes, recepción

6. Ventas (5 US, 50 SP)
   └─ Registro, clientes, ajuste inventario

7. Carrito (5 US, 45 SP)
   └─ Pedidos clientes, comprobantes, revisión

8. Reportes (5 US, 40 SP)
   └─ Ventas, compras, transferencias, dashboard
```

**❌ EXCLUIDO (Out-of-Scope):**
```
• Facturación electrónica (SIN - Bolivia)
• Pasarelas de pago automáticas
• Delivery tracking en tiempo real
• Aplicación web (solo móvil)
• Push notifications
• Chat en tiempo real
• Geolocalización
• Integración con WhatsApp Business
```

**Impacto de cambios:**
```
Si ALCANCE ↓ (se reduce):
  → TIEMPO ↓ (menos desarrollo)
  → COSTO ↓ (menos horas)
  → CALIDAD = (enfoque en lo esencial)

Si ALCANCE ↑ (se aumenta):
  → TIEMPO ↑ (más desarrollo)
  → COSTO ↑ (más horas/recursos)
  → CALIDAD = (riesgo si no se ajustan otros)
```

**Gestión de Cambios de Alcance (Change Management):**

| Cambio Solicitado | Evaluación | Impacto | Decisión |
|-------------------|------------|---------|----------|
| "Agregar notificaciones push" | +2 semanas | +$3,200 | ❌ Fuera de presupuesto |
| "Integrar facturación SIN" | +4 semanas | +$6,400 | ❌ Cambio mayor, fase 2 |
| "Mejorar UX de carrito" | +1 semana | +$1,600 | ✅ Dentro de contingencia |
| "Agregar dashboard gráfico" | Ya incluido | $0 | ✅ En alcance original |

---

#### 🎯 CALIDAD (Centro del Triángulo)

**Definición:** El grado en que el producto cumple con los requisitos y expectativas.

> **🔴 REGLA DE ORO:** La CALIDAD NUNCA es negociable. No importa qué vértice se ajuste (tiempo, costo, alcance), la calidad debe mantenerse constante y alta.

**Atributos de Calidad para Munani App:**

| Atributo | Descripción | Métrica | Mínimo Aceptable |
|----------|-------------|---------|------------------|
| **Funcionalidad** | Cumple todos los requisitos | User stories completadas | 100% |
| **Confiabilidad** | Funciona consistentemente | Uptime, crashes | 99% uptime, <1% crash rate |
| **Usabilidad** | Fácil de usar | SUS score | ≥70/100 |
| **Eficiencia** | Respuesta rápida | Tiempo de respuesta | <2 segundos |
| **Mantenibilidad** | Fácil de mantener | Code coverage, tech debt | ≥80%, <15% debt |
| **Seguridad** | Protege datos | Vulnerabilidades | 0 críticas, 0 altas |
| **Portabilidad** | Funciona en múltiples dispositivos | Dispositivos soportados | Android 7+, iOS 12+ |

**Estándares de Calidad Implementados:**

✅ **Código:**
- Clean Architecture (separación de capas)
- SOLID principles
- Code reviews obligatorios
- Linting automático (flutter_lints)
- Unit tests (≥80% coverage)
- Integration tests (flujos críticos)

✅ **Seguridad:**
- OWASP Top 10 compliance
- Rate limiting (5 intentos)
- Input sanitization
- Password strength validation
- Security logging
- Penetration testing

✅ **Performance:**
- Lazy loading
- Image caching
- Database indexing
- Background sync
- Optimized queries
- Performance profiling

✅ **UX:**
- Material 3 design
- Feedback inmediato
- Offline indicators
- Error messages claros
- Accessibility (WCAG 2.1 AA)

**Garantías de Calidad:**

```
📋 CHECKLIST DE CALIDAD (Quality Gates)

🔒 SEGURIDAD
  ├─ ☑️ 0 vulnerabilidades críticas (SonarQube)
  ├─ ☑️ 0 vulnerabilidades altas
  ├─ ☑️ Rate limiting implementado
  ├─ ☑️ Input sanitization en todos los forms
  └─ ☑️ Penetration testing aprobado

⚡ RENDIMIENTO
  ├─ ☑️ <2s tiempo de respuesta (90% de casos)
  ├─ ☑️ <100MB memoria RAM en uso
  ├─ ☑️ <50MB tamaño de app (APK)
  ├─ ☑️ 60fps en animaciones
  └─ ☑️ Funciona en dispositivos con 2GB RAM

✅ FUNCIONALIDAD
  ├─ ☑️ 100% user stories implementadas
  ├─ ☑️ 100% funcionalidad offline
  ├─ ☑️ Sincronización bidireccional 100% funcional
  ├─ ☑️ 0 bugs críticos
  └─ ☑️ <5 bugs menores

🧪 TESTING
  ├─ ☑️ ≥80% code coverage
  ├─ ☑️ Tests unitarios pasando (100%)
  ├─ ☑️ Tests de integración pasando (100%)
  ├─ ☑️ Smoke tests pasando
  └─ ☑️ Regression tests pasando

📱 COMPATIBILIDAD
  ├─ ☑️ Android 7.0+ (API 24+)
  ├─ ☑️ iOS 12.0+
  ├─ ☑️ Tablets (responsive)
  ├─ ☑️ Diferentes resoluciones
  └─ ☑️ Light/Dark mode

📚 DOCUMENTACIÓN
  ├─ ☑️ Manual de usuario completo
  ├─ ☑️ Manual técnico actualizado
  ├─ ☑️ API documentation
  ├─ ☑️ Comments en código crítico
  └─ ☑️ README actualizado
```

**Proceso de Aseguramiento de Calidad:**

```
1. PREVENCIÓN (Shift-Left Testing)
   └─ Code reviews → Linting → Static analysis

2. DETECCIÓN TEMPRANA
   └─ Unit tests → Integration tests → Automated CI/CD

3. VALIDACIÓN
   └─ UAT → Beta testing → Performance testing

4. MEJORA CONTINUA
   └─ Retrospectives → Refactoring → Tech debt sprints
```

---

### ⚖️ Escenarios de Balanceo del Triángulo

#### Escenario 1: 🚨 **Crisis - Sponsor pide adelantar lanzamiento 2 semanas**

**Situación:** Se necesita lanzar en 14 semanas en lugar de 16.

**Análisis de Impacto:**
```
TIEMPO: 16 semanas → 14 semanas (-12.5%)

Opciones:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

A) AUMENTAR COSTO (horas extra / más recursos)
   ├─ Costo adicional: +$3,200 (horas extra)
   ├─ Mantener alcance: 100%
   └─ Mantener calidad: ✅

B) REDUCIR ALCANCE (MVP)
   ├─ Costo: Sin cambio
   ├─ Reducir alcance: -20% (postergar reportes)
   └─ Mantener calidad: ✅

C) RECHAZAR (recomendado si compromete calidad)
   ├─ Explicar impacto al sponsor
   ├─ Proponer alternativa: Lanzamiento por fases
   └─ Fase 1: Core features (12 sem)
       Fase 2: Reportes avanzados (4 sem)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Decisión Recomendada:** Opción C (Lanzamiento por fases)
**Razón:** Mantiene calidad sin aumentar costo ni comprometer features críticas.

---

#### Escenario 2: 💰 **Recorte de Presupuesto - Reducción del 15%**

**Situación:** Sponsor reduce presupuesto a $39,542 (-$6,978)

**Análisis de Impacto:**
```
COSTO: $46,520 → $39,542 (-15%)

Opciones:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

A) REDUCIR ALCANCE (priorizar)
   ├─ Eliminar: Carrito de clientes (-20%)
   ├─ Tiempo: 16 semanas (sin cambio)
   └─ Calidad: ✅ (enfoque en core)

B) EXTENDER TIEMPO (reducir velocidad)
   ├─ Pasar de 3 a 2 desarrolladores
   ├─ Tiempo: 16 → 22 semanas (+37.5%)
   └─ Calidad: ✅ (mismo estándar)

C) NEGOCIAR (pago por fases)
   ├─ Fase 1: $25,000 (core features)
   ├─ Fase 2: $14,520 (features avanzadas)
   └─ Sponsor paga según cashflow
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Decisión Recomendada:** Opción A (Reducir alcance a MVP)
**Razón:** Entrega valor rápido, calidad alta, posibilidad de Fase 2.

---

#### Escenario 3: 📏 **Expansión de Alcance - "Agregar módulo de facturación SIN"**

**Situación:** Sponsor solicita agregar integración con SIN (Servicio de Impuestos Nacionales de Bolivia).

**Análisis de Impacto:**
```
ALCANCE: 13 módulos → 14 módulos (+7.7%)

Estimación del cambio:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• Complejidad: Alta (API SIN compleja)
• Tiempo adicional: +3 semanas
• Costo adicional: +$4,800 (3 semanas × 3 devs × 40h × $20/h)

Opciones:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

A) APROBAR CHANGE ORDER (aumentar tiempo y costo)
   ├─ Tiempo: 16 → 19 semanas (+18.7%)
   ├─ Costo: $46,520 → $51,320 (+10.3%)
   └─ Alcance: +Facturación SIN
   └─ Calidad: ✅ (sin compromiso)

B) POSTERGAR A FASE 2 (recomendado)
   ├─ Entregar proyecto original en 16 semanas
   ├─ Facturación SIN como proyecto separado
   ├─ Presupuesto adicional: $8,000 - $12,000
   └─ Timeline: +1-2 meses post-lanzamiento

C) RECHAZAR (si no es crítico para negocio)
   ├─ Enfoque en alcance original
   ├─ Evaluación de prioridad vs. impacto
   └─ Alternativa: Facturación manual/externa
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Decisión Recomendada:** Opción B (Postergar a Fase 2)
**Razón:** Evita scope creep, mantiene timeline y calidad del proyecto original.

---

### 📊 Matriz de Decisiones del Triángulo

**Regla de Oro para Toma de Decisiones:**

| Si cambia... | Entonces... | Pero siempre... |
|--------------|-------------|-----------------|
| ⏱️ **TIEMPO ↓** | Aumentar COSTO o Reducir ALCANCE | Mantener CALIDAD |
| ⏱️ **TIEMPO ↑** | Posible reducir COSTO o Aumentar ALCANCE | Mantener CALIDAD |
| 💰 **COSTO ↓** | Aumentar TIEMPO o Reducir ALCANCE | Mantener CALIDAD |
| 💰 **COSTO ↑** | Reducir TIEMPO o Aumentar ALCANCE | Mantener CALIDAD |
| 📏 **ALCANCE ↓** | Reducir TIEMPO y/o COSTO | Mantener CALIDAD |
| 📏 **ALCANCE ↑** | Aumentar TIEMPO y/o COSTO | Mantener CALIDAD |

**Fórmula de Priorización:**

```
CALIDAD = constante (no negociable)

Si: TIEMPO = fijo, COSTO = variable
    → Ajustar ALCANCE primero, luego COSTO si es necesario

Si: COSTO = fijo, TIEMPO = variable
    → Ajustar ALCANCE primero, luego TIEMPO si es necesario

Si: ALCANCE = fijo, TIEMPO = variable
    → Ajustar COSTO primero, luego TIEMPO si es necesario
```

---

### 🎯 Aplicación Práctica en Munani App

**Configuración Inicial del Triángulo:**

```
                        🎯 CALIDAD
                   (Estándares ALTOS)
                           /\
                          /  \
                         /    \
                        /      \
                       /        \
                      /          \
                     /   40 USER  \
                    /    STORIES    \
                   /   13 MÓDULOS    \
                  /____________________\
            ⏱️ 16 SEMANAS        💰 $46,520
             (4 meses)            (FIJO)
```

**Restricciones del Proyecto:**

| Vértice | Estado | Flexibilidad |
|---------|--------|--------------|
| **TIEMPO** | 🔒 Preferiblemente fijo (4 meses) | 🟡 Media (puede extender 1-2 semanas) |
| **COSTO** | 🔒 Fijo ($46,520) | 🔴 Baja (max +10% contingencia) |
| **ALCANCE** | 🔓 Negociable (MVP posible) | 🟢 Alta (puede priorizar) |
| **CALIDAD** | 🔒 **NO NEGOCIABLE** | 🔴 **CERO** (estándares altos siempre) |

**Estrategia de Gestión:**

1. **CALIDAD es el CORE** → Definir Definition of Done estricto
2. **COSTO es fijo** → Presupuesto pre-aprobado con 10% contingencia
3. **TIEMPO es target** → 16 semanas ideal, +1-2 semanas aceptable
4. **ALCANCE es flexible** → Priorizar con MoSCoW

**Priorización MoSCoW del Alcance:**

```
🔴 MUST HAVE (Crítico - 60% del alcance)
├─ Autenticación
├─ Productos + Variantes
├─ Inventario
├─ Transferencias
└─ Sincronización offline

🟠 SHOULD HAVE (Importante - 25% del alcance)
├─ Compras + Proveedores
├─ Ventas
└─ Clientes

🟡 COULD HAVE (Deseable - 10% del alcance)
├─ Carrito de compras
└─ Reportes básicos

🟢 WON'T HAVE (Futuro - 5% del alcance)
├─ Reportes avanzados
├─ Dashboard analytics
└─ Features no críticas
```

**Plan de Contingencia por Escenarios:**

| Riesgo | Probabilidad | Impacto en Triángulo | Plan de Acción |
|--------|--------------|----------------------|----------------|
| Retraso técnico | Media | TIEMPO +1 sprint | Reducir ALCANCE (COULD HAVE) |
| Bug crítico | Baja | TIEMPO +1 semana | Usar CONTINGENCIA, priorizar fix |
| Cambio de sponsor | Baja | ALCANCE +20% | CHANGE ORDER: +TIEMPO +COSTO |
| Pérdida de recurso | Baja | TIEMPO +2 semanas | Redistribuir, contratar temporal |

---

### ✅ Conclusión del Triángulo de Hierro

**Para el éxito de Munani App:**

1. **CALIDAD es innegociable** ✅
   - Estándares de código altos (Clean Architecture, SOLID)
   - Seguridad robusta (OWASP compliance)
   - Performance óptimo (<2s respuesta)
   - Testing exhaustivo (≥80% coverage)

2. **Comunicación transparente con Sponsor** 📞
   - Reportes semanales de progreso
   - Alertas tempranas de desviaciones
   - Opciones claras ante cambios

3. **Gestión proactiva de cambios** 🎯
   - Change Management process definido
   - Evaluación de impacto en triángulo
   - Aprobación formal para cambios de alcance

4. **Flexibilidad con priorización** 🎪
   - MVP definido (MUST HAVE)
   - Alcance ajustable según necesidad
   - Roadmap de Fase 2 preparado

**Mensaje Final:**

> "Podemos entregar RÁPIDO, BARATO o con MUCHO ALCANCE...
> pero SIEMPRE con CALIDAD ALTA.
> Elige dos de los primeros tres, la calidad viene garantizada." 💯

---

## 📚 REFERENCIAS Y RECURSOS

### Metodologías y Marcos de Trabajo:
- 📖 **Scrum Guide 2020** - scrum.org
- 📖 **PMBOK Guide 7th Edition** - PMI
- 📖 **Agile Manifesto** - agilemanifesto.org

### Herramientas de Gestión:
- 🛠️ **Jira** - jira.atlassian.com (Gestión de sprints)
- 🛠️ **Trello** - trello.com (Kanban boards)
- 🛠️ **GitHub Projects** - github.com (Integrado con código)
- 🛠️ **Miro** - miro.com (Retrospectivas virtuales)

### Recursos Técnicos:
- 💻 **Flutter Docs** - docs.flutter.dev
- 💻 **Supabase Docs** - supabase.com/docs
- 💻 **Isar Database** - isar.dev
- 🔒 **OWASP Top 10** - owasp.org/Top10

### Estándares de Calidad:
- ✅ **ISO/IEC 25010** - Calidad de software
- ✅ **NIST 800-63B** - Autenticación digital
- ✅ **WCAG 2.1** - Accesibilidad web

---

## 📝 CONTROL DE VERSIONES DE ESTE DOCUMENTO

| Versión | Fecha | Autor | Cambios |
|---------|-------|-------|---------|
| 1.0 | 2025-11-12 | David (PM) | Documento inicial completo |

---

## ✅ APROBACIONES

| Rol | Nombre | Firma | Fecha |
|-----|--------|-------|-------|
| **Sponsor** | Danae Revollo | _____________ | ____/____/____ |
| **Project Manager** | David | _____________ | ____/____/____ |
| **Developer** | Jonas | _____________ | ____/____/____ |
| **Developer** | Daniel | _____________ | ____/____/____ |

---

**🎯 Documento preparado por:** Equipo Munani App V2
**📅 Última actualización:** 2025-11-12
**📧 Contacto:** [david@munaniapp.com](mailto:david@munaniapp.com)

---

**🔒 CONFIDENCIAL** - Este documento contiene información propietaria del proyecto Munani App V2.

