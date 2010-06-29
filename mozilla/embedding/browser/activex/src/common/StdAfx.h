/* -*- Mode: C++; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*- */
/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1/GPL 2.0/LGPL 2.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is mozilla.org code.
 *
 * The Initial Developer of the Original Code is
 * Netscape Communications Corporation.
 * Portions created by the Initial Developer are Copyright (C) 1998
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *   Adam Lock <adamlock@eircom.net>
 *
 * Alternatively, the contents of this file may be used under the terms of
 * either the GNU General Public License Version 2 or later (the "GPL"), or
 * the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
 * in which case the provisions of the GPL or the LGPL are applicable instead
 * of those above. If you wish to allow use of your version of this file only
 * under the terms of either the GPL or the LGPL, and not to allow others to
 * use your version of this file under the terms of the MPL, indicate your
 * decision by deleting the provisions above and replace them with the notice
 * and other provisions required by the GPL or the LGPL. If you do not delete
 * the provisions above, a recipient may use your version of this file under
 * the terms of any one of the MPL, the GPL or the LGPL.
 *
 * ***** END LICENSE BLOCK ***** */

// stdafx.h : include file for standard system include files,
//      or project specific include files that are used frequently,
//      but are changed infrequently

#if !defined(AFX_STDAFX_H__1339B542_3453_11D2_93B9_000000000000__INCLUDED_)
#define AFX_STDAFX_H__1339B542_3453_11D2_93B9_000000000000__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

  // under MSVC shut off copious warnings about debug symbol too long
#ifdef _MSC_VER
  #pragma warning( disable: 4786 )
#endif

#include "jstypes.h"
#include "prtypes.h"

// Mozilla headers

#include "jscompat.h"

#include "prthread.h"
#include "prprf.h"
#include "nsIComponentManager.h"
#include "nsIServiceManager.h"
#include "nsStringAPI.h"
#include "nsCOMPtr.h"
#include "nsComponentManagerUtils.h"
#include "nsServiceManagerUtils.h"

#include "nsIDocument.h"
#include "nsIDocumentObserver.h"

#include "nsIDOMNode.h"
#include "nsIDOMNodeList.h"
#include "nsIDOMDocument.h"
#include "nsIDOMDocumentType.h"
#include "nsIDOMElement.h"

#undef _WIN32_WINNT
#define _WIN32_WINNT 0x0400
#define _ATL_APARTMENT_THREADED
#define _ATL_STATIC_REGISTRY
// #define _ATL_DEBUG_INTERFACES

// ATL headers
// The ATL headers that come with the platform SDK have bad for scoping
#if _MSC_VER >= 1400
#pragma conform(forScope, push, atlhack, off)
#endif

#ifdef WINCE
/* atlbase.h on WINCE has a bug, in that it tries to use
 * GetProcAddress with a wide string, when that is explicitly not
 * supported.  So we use C++ to overload that here, and implement
 * something that works.
 */
#include <windows.h>
static FARPROC GetProcAddressA(HMODULE hMod, wchar_t *procName) {
  FARPROC ret = NULL;
  int len = wcslen(procName);
  char *s = new char[len + 1];

  for (int i = 0; i < len; i++) {
    s[i] = (char) procName[i];
  }
  s[len-1] = 0;

  ret = ::GetProcAddress(hMod, s);
  delete [] s;

  return ret;
}
#endif

#include <atlbase.h>

//You may derive a class from CComModule and use it if you want to override
//something, but do not change the name of _Module
extern CComModule _Module;
#include <atlcom.h>
#include <atlctl.h>

#if _MSC_VER >= 1400
#pragma conform(forScope, pop, atlhack)
#endif

#include <mshtml.h>
#include <mshtmhst.h>
#include <docobj.h>

// New winsock2.h doesn't define this anymore
typedef long int32;

// Turn off warnings about debug symbols for templates being too long
#pragma warning(disable : 4786)

#define TRACE_METHOD(fn) \
     { \
         ATLTRACE(_T("0x%04x %s()\n"), (int) GetCurrentThreadId(), _T(#fn)); \
     }
#define TRACE_METHOD_ARGS(fn, pattern, args) \
    { \
        ATLTRACE(_T("0x%04x %s(") _T(pattern) _T(")\n"), (int) GetCurrentThreadId(), _T(#fn), args); \
    }

//{{AFX_INSERT_LOCATION}}
// Microsoft Developer Studio will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_STDAFX_H__1339B542_3453_11D2_93B9_000000000000__INCLUDED)
