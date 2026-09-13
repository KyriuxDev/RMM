/*
 * hwinfo.h — Hardware detection, registry queries, WMI.
 */
#ifndef HWINFO_H
#define HWINFO_H

#include "common.h"

/* COM lifecycle */
void com_init(void);
void com_deinit(void);

/* Populate HardwareInfo struct with host data. */
void gather_hardware(HardwareInfo *info);

/* Medir uso de CPU, RAM y disco al momento de la llamada. */
void gather_telemetry(Telemetria *t);

/* Inventario: software instalado + estado del antivirus.
   Liberar con free_inventario(). */
void gather_software(Inventario *inv);
void free_inventario(Inventario *inv);

/* Set autostart entry in HKCU\...\Run. */
void set_autostart(void);

#endif /* HWINFO_H */
