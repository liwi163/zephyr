/*
 * Copyright (c) 2014 Wind River Systems, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * @file
 * @brief CPU power management
 *
 * CPU power management routines.
 */

#define _ASMLANGUAGE

#include <kernel_structs.h>
#include <offsets_short.h>
#include <toolchain.h>
#include <sections.h>
#include <arch/cpu.h>

GTEXT(nano_cpu_idle)
GTEXT(nano_cpu_atomic_idle)
GDATA(nano_cpu_sleep_mode)

SECTION_VAR(BSS, nano_cpu_sleep_mode)
	.word 0

/*
 * @brief Put the CPU in low-power mode
 *
 * This function always exits with interrupts unlocked.
 *
 * void nanCpuIdle(void)
 */

SECTION_FUNC(TEXT, nano_cpu_idle)

#ifdef CONFIG_KERNEL_EVENT_LOGGER_SLEEP
	push_s blink
	jl    _sys_k_event_logger_enter_sleep
	pop_s blink
#endif

	ld r1, [nano_cpu_sleep_mode]
	or r1, r1, (1 << 4) /* set IRQ-enabled bit */
	sleep r1
	j_s [blink]
	nop

/*
 * @brief Put the CPU in low-power mode, entered with IRQs locked
 *
 * This function exits with interrupts restored to <key>.
 *
 * void nano_cpu_atomic_idle(unsigned int key)
 */
SECTION_FUNC(TEXT, nano_cpu_atomic_idle)

#ifdef CONFIG_KERNEL_EVENT_LOGGER_SLEEP
	push_s blink
	jl    _sys_k_event_logger_enter_sleep
	pop_s blink
#endif

	ld r1, [nano_cpu_sleep_mode]
	or r1, r1, (1 << 4) /* set IRQ-enabled bit */
	sleep r1
	j_s.d [blink]
	seti r0
