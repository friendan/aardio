/*
可遵循 aardio 用户协议与 aardio 开源许可证在 aardio 程序中自由使用本组件以及本组件源码,
禁止在非 aardio 开发的程序中引用本组件的任何部份(包含但不限于本组件源码、使用此源码生成的 DLL )
*/
using System;
using System.CodeDom.Compiler;
using System.Collections;
using System.Reflection;
using System.Runtime.InteropServices;
using System.IO;
using System.Collections.Generic;

namespace Aardio.InteropServices
{
    [Guid("7C856F49-0310-40F6-A1F2-B7BBB4C48F30")] //不可修改 GUID
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    [ComImport]
    public interface IDispatchableObject
    {
    }

    [ClassInterface(ClassInterfaceType.AutoDispatch), ComVisible(true)]
    public class DispatchableObject: IDispatchableObject, IEnumerable
    {
        private object underlyingObject;
        private Type type;
        public DispatchableObject(object obj, bool byRef) { underlyingObject = obj; type = underlyingObject.GetType(); ByRef = byRef; }
        public bool ByRef; 
        
        [DispId(0)]
        public object this[int index]
        {
            get
            {
                if (underlyingObject is Array arr) return arr.GetValue(index);
                return null;
            }
            set
            {
                if (underlyingObject is Array arr) arr.SetValue(value,index); 
            }
        } 

        public int Length
        {
            get {
                if (underlyingObject is Array arr) return arr.Length;
                return 0;
            } 
        }

        public Object Value
        {
            get {  return underlyingObject; }
            set { underlyingObject = value; }
        }

       
        public object Invoke(params object[] args) {
            if( typeof(Delegate).IsAssignableFrom(type))
            {
                return type.InvokeMember("", BindingFlags.InvokeMethod, null, underlyingObject, args);
            }
            
            return underlyingObject;  
        }
        
        public override string ToString()
        {
            return underlyingObject.ToString();
        }
        
        public IEnumerator GetEnumerator()
        {
            if (underlyingObject is Array arr) return arr.GetEnumerator();
            if (underlyingObject is IEnumerable) return type.InvokeMember("GetEnumerator", BindingFlags.InvokeMethod | BindingFlags.Instance | BindingFlags.Public, null, underlyingObject, null) as IEnumerator;
            throw new NotImplementedException();
        }
    }

    //*注意 COM 类里传来的 .Net 对象也会变成 System.__ComObject,非 COM 类才会还原 .Net 对象*/
    [ClassInterface(ClassInterfaceType.AutoDispatch), ComVisible(true)]
    public class Utility
    {
        public static Type DispatchableObjectType = typeof(DispatchableObject);
        static Type ColorType = typeof(System.Drawing.Color);
        static Type IntPtrType = typeof(System.IntPtr);
        static Type UIntPtrType = typeof(System.UIntPtr);

        public static object WrapNonPrimitiveValueToAnyObjectRef(object ret)
        { 
            if (ret == null) return ret;

            Type t = ret.GetType();
            if (t.IsPrimitive || t.IsEnum) return ret;

            if (!t.IsValueType)
            {
               if(t.IsArray){
                    Type tEle = t.GetElementType();
                    Array arr = ret as Array;

                    if (arr.GetLength(0) ==0 ) return new Aardio.InteropServices.DispatchableObject(ret, false);
                    if (tEle.IsPrimitive || tEle.IsEnum || (typeof(string) == tEle) ) return ret;

                    if (tEle.IsArray)
                    {
                        object first = WrapNonPrimitiveValueToAnyObjectRef(arr.GetValue(0));
                        if( (first!=null) && (first.GetType() == DispatchableObjectType))
                        {
                            return new Aardio.InteropServices.DispatchableObject(ret, false);
                        }
                    }
                    else
                    {
                        //System.Drawing.Color 如果是数组不作转换
                        return new DispatchableObject(ret, false);
                    }
                }
                else if(t.IsClass)
                {
                    try
                    {
                        var ptr = Marshal.GetIDispatchForObject(ret);
                        if (ptr != null) Marshal.Release(ptr);
                    }
                    catch (InvalidOperationException)
                    {
                        return new Aardio.InteropServices.DispatchableObject(ret, false);
                    }
                    catch (Exception)
                    {
                        return ret;
                    }
                }
                

                 return ret;
            }
            
            if (t == ColorType) return ((System.Drawing.Color)ret).ToArgb();
            return new DispatchableObject(ret,false);
        }

        public object CreateAnyObject(object v,bool byRef = false)
        { 
            return new DispatchableObject(v, byRef);
        }
        
        private void setOutValue(object []outArgs,object [] invokeArgs2)
        {
            for (int i = 0; i < outArgs.Length; i++)
            {
                if(outArgs[i] != null )
                {
                    (outArgs[i] as DispatchableObject).Value = invokeArgs2[i];
                }
            }
        }
        
        public CCodeCompiler CreateCompiler(string provideType)
        {
            object obj = this.loadAssembly("System").CreateInstance(provideType);
            if (obj == null)
            {
                return null;
            }
            return new CCodeCompiler(obj as CodeDomProvider);
        }


        public object GetTypeByName(object assembly, string typeName)
        {
            return (assembly as Assembly).GetType(typeName,false);
        }

        public object GetClassTypeByName(object assembly, string typeName)
        {
            Type t = (assembly as Assembly).GetType(typeName, false);
            if (t != null && t.IsClass) return t;
            return null;
        }

        public object InvokeMember2(object tAnyObject , object assemblyName, string typeName, string methodName, int invokeAttr, object args, object target)
        {
            try
            {
                Type tAny = tAnyObject as Type;
                Assembly assembly = assemblyName as Assembly;

                if (assembly == null)
                {
                    assembly = this.loadAssembly(assemblyName as string);
                }
                if (assembly != null)
                {
                    if (tAny == null) tAny = assembly.GetType(typeName);
                    if (((BindingFlags)invokeAttr & BindingFlags.CreateInstance) == BindingFlags.CreateInstance)
                    {

                        if (tAny != null && tAny.IsClass)
                        {
                            return CreateInstanceByClassType(tAny, (args as ArrayList), target);
                        }

                    }

                    if( (invokeAttr & (16 | 8 | 256)) == (16 | 8 | 256))
                    {
                        if( (target == null) && (typeName !=null) && (methodName != null) )
                        {
                            Type tAny2 = assembly.GetType(typeName + "." + methodName);
                            if (tAny2 != null )
                            {
                                if(tAny2.IsClass) return CreateInstanceByClassType(tAny2, (args as ArrayList), target);
                                if (tAny2.IsValueType && !tAny2.IsEnum && !tAny2.IsPrimitive)
                                {
                                    return CreateInstanceByClassType(tAny2, (args as ArrayList), target);
                                }
                            }
                        }

                        if (tAny == null) throw new MissingMethodException();
                    }

                    return InvokeMemberByType(tAny, methodName, invokeAttr, args, target);
                }

            }
            catch (TargetInvocationException targetEx)
            {
                if (targetEx.InnerException != null)
                {
                    throw targetEx.InnerException;
                }
            }

            return null;

        }


        public object InvokeMember(object assemblyName, string typeName, string methodName, int invokeAttr, object args, object target)
        {
            try
            {
                Assembly assembly = assemblyName as Assembly;
                if (assembly == null)
                {
                    assembly = this.loadAssembly(assemblyName as string);
                }
                if (assembly != null)
                {

                    Type tAny = assembly.GetType(typeName);
                    if (((BindingFlags)invokeAttr & BindingFlags.CreateInstance) == BindingFlags.CreateInstance)
                    {

                        if (tAny != null && tAny.IsClass)
                        {
                            return CreateInstanceByClassType(tAny, (args as ArrayList), target);
                        }

                    }

                    if (((BindingFlags)invokeAttr & BindingFlags.InvokeMethod) == BindingFlags.InvokeMethod)
                    {
                        if (tAny == null)
                        {
                            tAny = assembly.GetType(typeName + "." + methodName);
                            if (tAny != null && tAny.IsClass && ((invokeAttr & (16 | 8 | 256)) == (16 | 8 | 256)))
                            {
                                return CreateInstanceByClassType(tAny, (args as ArrayList), target);
                            }
                        }

                        if (tAny == null) throw new MissingMethodException();
                    }

                    return InvokeMemberByType(tAny, methodName, invokeAttr, args, target);
                }

            }
            catch (TargetInvocationException targetEx)
            {
                if (targetEx.InnerException != null)
                {
                    throw targetEx.InnerException;
                }
            }

            return null;

        }

        public object InvokeObjectMember(object target, string methodName, int invokeAttr, object args)
        {
            if (target == null)
            {
                return null;
            }

            try
            {
                return InvokeMemberByType(target.GetType(), methodName, invokeAttr, args, target);
            }
            catch (TargetInvocationException targetEx)
            {
                if (targetEx.InnerException != null)
                {
                    throw targetEx.InnerException;
                }
            }

            return null;
        }


        public object RoundTrip(object target)
        {  
            return RoundTripRaw(target);
        } 

        [ComVisible(false)]
        public object RoundTripRaw(object target)
        {
            Type tAny = target.GetType();
            if  (tAny == DispatchableObjectType  )
            {
                target = (target as DispatchableObject).Value; 
            }

            return WrapNonPrimitiveValueToAnyObjectRef(target);
        }

        public object InvokeMemberByType(Type tAny, string methodName, int invokeAttr, object args, object target)
        {
            ArrayList argArrayList = (args as ArrayList);
            if ( (tAny == DispatchableObjectType) &&  (target != null)  )
            {
                DispatchableObject dispObj = (target as DispatchableObject);
                target = dispObj.Value;
                tAny = target.GetType();

                if((((BindingFlags)invokeAttr & BindingFlags.InvokeMethod)!= BindingFlags.InvokeMethod) && (methodName == "Value") )
                {
                    Type tEle = tAny;
                    if (tAny.IsArray) tEle = tAny.GetElementType();

                    if (tEle.IsPrimitive || tEle.IsEnum || tEle.IsArray || (tEle == typeof(string) )   ){
                        if (((BindingFlags)invokeAttr & BindingFlags.GetField) == BindingFlags.GetField)
                        {
                            return target;
                        }
                        else if (((BindingFlags)invokeAttr & BindingFlags.SetField) == BindingFlags.SetField)
                        {
                            if (argArrayList[0].GetType().Equals(tAny)) dispObj.Value = argArrayList[0];
                            else dispObj.Value = Convert.ChangeType(argArrayList[0], tAny); 
                            return null;
                        }
                    }
                }
            }
             
            if ((argArrayList == null) || (argArrayList.Count == 0) )
            {
                //不需要匹配参数类型，不需要自动转换。
                return WrapNonPrimitiveValueToAnyObjectRef(tAny.InvokeMember(methodName, (BindingFlags)invokeAttr | BindingFlags.IgnoreReturn, null, target, null));
            }

            if (((BindingFlags)invokeAttr & BindingFlags.InvokeMethod) == BindingFlags.InvokeMethod)
            {
                bool hasOutValues = false;
                object[] outArgs  = new object[argArrayList.Count];
                Type[] argTypeArray = new Type[argArrayList.Count];
                for (int i = 0; i < argArrayList.Count; i++)
                {
                    argTypeArray[i] = argArrayList[i] != null ? argArrayList[i].GetType() : null;
                    if (argTypeArray[i] == DispatchableObjectType) {
                        DispatchableObject v = (argArrayList[i] as DispatchableObject);
                        if (v.ByRef)
                        {
                            outArgs[i] = argArrayList[i];
                            hasOutValues = true;
                        }

                        argArrayList[i] = v.Value;
                    }
                }
                if (!hasOutValues) outArgs = null;

                MethodInfo m = null;
                try
                {
                    m = tAny.GetMethod(methodName, (BindingFlags)invokeAttr | BindingFlags.IgnoreReturn, null, argTypeArray, null);
                }
                catch (SystemException)
                {

                }

                if (m != null)
                {
                    object []invokeArgs3 = argArrayList != null ? argArrayList.ToArray() : null;
                    object ret2 = WrapNonPrimitiveValueToAnyObjectRef( m.Invoke(target, invokeArgs3) );
                    if (outArgs != null) setOutValue(outArgs, invokeArgs3);
                    return ret2;
                } 

                 
                MethodInfo[] ms = tAny.GetMethods((BindingFlags)invokeAttr | BindingFlags.IgnoreReturn);
                bool failed = true;

                object[] invokeArgs2 = null;
                object ret = InvokeMemberBaseMethodInfo(methodName, ms, argArrayList, ref failed, target, invokeAttr, ref invokeArgs2);
                if (!failed)
                { 
                    ret = WrapNonPrimitiveValueToAnyObjectRef(ret);
                    if ((outArgs != null) && ( invokeArgs2!=null ) ) setOutValue(outArgs, invokeArgs2);
                    return ret;
                } 
            }
            
            if (((BindingFlags)invokeAttr & BindingFlags.SetProperty) == BindingFlags.SetProperty)
            { 
                for (int i = 0; i < argArrayList.Count; i++)
                { 
                    if (argArrayList[i] is DispatchableObject v)
                    {  
                        argArrayList[i] = v.Value; 
                    }
                }

                PropertyInfo prop = null;
                try
                {
                    prop = tAny.GetProperty(methodName, (BindingFlags)invokeAttr);
                }
                catch(AmbiguousMatchException)
                {
                    ArrayList arrList = new ArrayList();
                    PropertyInfo []props = tAny.GetProperties( (BindingFlags)invokeAttr);
                    
                    for (int i = 0; i < props.Length; i++)
                    { 
                        if (props[i].Name == methodName)
                        { 
                            arrList.Add(props[i].GetSetMethod());
                        }
                    }

                    if (arrList.Count > 0) {

                        MethodInfo[] ms = new MethodInfo[arrList.Count];
                        for (int i = 0; i < ms.Length; i++)
                        {
                            ms[i] = arrList[i] as MethodInfo; 
                        }
                         
                        bool failed = true; 
                        object[] invokeArgs2 = null;
                        InvokeMemberBaseMethodInfo(ms[0].Name, ms, argArrayList, ref failed, target, invokeAttr, ref invokeArgs2);
                        if (!failed)
                        {
                            return null;
                        }
                    }

                }

                if (prop != null)
                {
                    invokeAttr = invokeAttr & ~(int)BindingFlags.SetField;
                    var lastIndex = argArrayList.Count - 1;
                    if (  argArrayList[lastIndex] != null)
                    { 
                        MethodInfo ms = prop.GetSetMethod(); 

                        var parameters = ms.GetParameters(); 
                        if (parameters.Length == argArrayList.Count)
                        { 
                            var paramType = parameters[lastIndex].ParameterType;
                            Type nullableUnderlyingType = Nullable.GetUnderlyingType(paramType);
                            if (nullableUnderlyingType != null)
                            {
                                paramType = nullableUnderlyingType;
                            }
                            //string a = paramType.Name;

                            var argType = argArrayList[lastIndex].GetType();
                            if (argType == DispatchableObjectType)
                            {
                                argArrayList[lastIndex] = (argArrayList[lastIndex] as DispatchableObject).Value;
                                argType = argArrayList[lastIndex].GetType();
                            }
                            var argTypeCode = Type.GetTypeCode(argType);

                            Type enumType = null;
                            if (paramType.IsEnum)
                            {
                                enumType = paramType;
                                paramType = Enum.GetUnderlyingType(enumType);
                            }

                            if (!paramType.IsAssignableFrom(argType))
                            {
                                if (typeof(Delegate).IsAssignableFrom(paramType) && argType.IsCOMObject )
                                {
                                    var dd = new DispatchableDelegate(argArrayList[lastIndex]);
                                    argArrayList[lastIndex] = (object)dd.CreateDelegate(paramType);
                                }
                                else if (argTypeCode == TypeCode.Double || argTypeCode == TypeCode.Int32)
                                {

                                    if (IsNumericType(paramType))
                                    {
                                        argArrayList[lastIndex] = Convert.ChangeType(argArrayList[lastIndex], paramType);
                                    }
                                    else if (paramType == ColorType)
                                    {
                                        argArrayList[lastIndex] = ConvertNumToColor(argArrayList[lastIndex], argTypeCode);
                                    }
                                    else if (paramType == IntPtrType && argTypeCode == TypeCode.Int32 )
                                    {
                                        argArrayList[lastIndex] = new System.IntPtr( (int) argArrayList[lastIndex]  );
                                    }
                                    else if (paramType == UIntPtrType && argTypeCode == TypeCode.Int32)
                                    {
                                        argArrayList[lastIndex] = new  System.UIntPtr( (uint)(int) argArrayList[lastIndex]);
                                    }
                                }
                                else if (paramType.IsArray && argType.IsArray)
                                {
                                    var paramEleType = paramType.GetElementType();
                                    var argEleType = argType.GetElementType();
                                    var argEleTypeCode = Type.GetTypeCode(argEleType);

                                    if ((argEleTypeCode == TypeCode.Double) && IsNumericType(paramEleType))
                                    {

                                        var srcArr = (argArrayList[lastIndex] as double[]);
                                        var dstArr = Array.CreateInstance(paramEleType, srcArr.Length);
                                        for (int n = 0; n < srcArr.Length; n++)
                                        {
                                            dstArr.SetValue(Convert.ChangeType(srcArr[n], paramEleType), n);
                                        }

                                        argArrayList[lastIndex] = dstArr;
                                    }

                                }

                            }

                            if (enumType != null) argArrayList[lastIndex] = Enum.ToObject(enumType, argArrayList[lastIndex]);
                        }

                    }
                }
            }



            if (((BindingFlags)invokeAttr & BindingFlags.SetField) == BindingFlags.SetField)
            {
                /*
                for (int i = 0; i < argArrayList.Count; i++)
                {
                    if (argArrayList[i] is DispatchableObject v)
                    {
                        argArrayList[i] = v.Value;
                    }
                }
                */

                FieldInfo field = tAny.GetField(methodName, (BindingFlags)invokeAttr);
                if (field != null)
                {
                    invokeAttr = invokeAttr & ~(int)BindingFlags.SetProperty;

                    if (  argArrayList[0] != null)
                    {
                        var paramType = field.FieldType;
                        Type nullableUnderlyingType = Nullable.GetUnderlyingType(paramType);
                        if (nullableUnderlyingType != null)
                        {
                            paramType = nullableUnderlyingType;
                        }

                        var argType = argArrayList[0].GetType();
                        if (argType == DispatchableObjectType)
                        {
                            argArrayList[0] = (argArrayList[0] as DispatchableObject).Value;
                            argType = argArrayList[0].GetType();
                        }

                        var argTypeCode = Type.GetTypeCode(argType);

                        Type enumType = null;
                        if (paramType.IsEnum)
                        {
                            enumType = paramType;
                            paramType = Enum.GetUnderlyingType(enumType);
                        }

                        if (!paramType.IsAssignableFrom(argType))
                        {

                            if (typeof(Delegate).IsAssignableFrom(paramType) && argType.IsCOMObject)
                            {
                                var dd = new DispatchableDelegate(argArrayList[0]);
                                argArrayList[0] = (object)dd.CreateDelegate(paramType);
                            }
                            else if ((argTypeCode == TypeCode.Double) || (argTypeCode == TypeCode.Int32))
                            {

                                if (IsNumericType(paramType))
                                {
                                    argArrayList[0] = Convert.ChangeType(argArrayList[0], paramType);
                                }
                                else if (paramType == ColorType)
                                {
                                    argArrayList[0] = ConvertNumToColor(argArrayList[0], argTypeCode);
                                }
                                else if (paramType == IntPtrType && argTypeCode == TypeCode.Int32)
                                {
                                    argArrayList[0] = new System.IntPtr((int)argArrayList[0]);
                                }
                                else if (paramType == UIntPtrType && argTypeCode == TypeCode.Int32)
                                {
                                    argArrayList[0] = new System.UIntPtr((uint)(int)argArrayList[0]);
                                }
                            }
                            else if (paramType.IsArray && argType.IsArray)
                            {
                                var paramEleType = paramType.GetElementType();
                                var argEleType = argType.GetElementType();
                                var argEleTypeCode = Type.GetTypeCode(argEleType);

                                if ((argEleTypeCode == TypeCode.Double) && IsNumericType(paramEleType))
                                {

                                    var srcArr = (argArrayList[0] as double[]);
                                    var dstArr = Array.CreateInstance(paramEleType, srcArr.Length);
                                    for (int n = 0; n < srcArr.Length; n++)
                                    {
                                        dstArr.SetValue(Convert.ChangeType(srcArr[n], paramEleType), n);
                                    }

                                    argArrayList[0] = dstArr;
                                }

                            }

                        }

                        if (enumType != null) argArrayList[0] = Enum.ToObject(enumType, argArrayList[0]);
                    }
                }
            }

            if (((BindingFlags)invokeAttr & (BindingFlags.SetProperty | BindingFlags.SetField) ) == (BindingFlags.SetProperty | BindingFlags.SetField))
            {
                EventInfo eventInfo = tAny.GetEvent(methodName);
                if (eventInfo != null)
                {
                    Type handlerType = eventInfo.EventHandlerType;
                    //MethodInfo invokeMethod = handlerType.GetMethod("Invoke");

                    if(!(typeof(Delegate).IsAssignableFrom(argArrayList[0].GetType().BaseType)) )
                    {
                        var dd = new DispatchableDelegate(argArrayList[0]);
                        eventInfo.AddEventHandler(target, dd.CreateDelegate(handlerType));
                    }
                    else
                    {
                        eventInfo.AddEventHandler(target,(Delegate) argArrayList[0]);
                    }
                    

                    return null;
                }
            }

            if ((methodName == "Item") && (target is Array arr) )
            {  
                if (((BindingFlags)invokeAttr & BindingFlags.GetProperty) == BindingFlags.GetProperty)
                {
                    return WrapNonPrimitiveValueToAnyObjectRef(arr.GetValue((int)argArrayList[0]));
                }
                else if (((BindingFlags)invokeAttr & BindingFlags.SetProperty) == BindingFlags.SetProperty)
                {
                    arr.SetValue(argArrayList[1], (int)argArrayList[0]);
                    return null;
                } 
            }

            return WrapNonPrimitiveValueToAnyObjectRef( tAny.InvokeMember(methodName, (BindingFlags)invokeAttr | BindingFlags.IgnoreReturn, null, target, (argArrayList != null) ? argArrayList.ToArray() : null) ); 
        }

        private object CreateInstanceByClassType(Type tClass, ArrayList argArrayList, object target)
        {
            if( (argArrayList == null)  || (argArrayList.Count == 0))
            {
                return WrapNonPrimitiveValueToAnyObjectRef(tClass.InvokeMember("", (BindingFlags)BindingFlags.CreateInstance | BindingFlags.IgnoreReturn, null, target, null));
            }
        

            Type[] argTypeArray = new Type[argArrayList.Count]; 

            bool hasOutValues = false;
            object[] outArgs = new object[argArrayList.Count]; 
            for (int i = 0; i < argArrayList.Count; i++)
            {
                argTypeArray[i] = argArrayList[i] != null ? argArrayList[i].GetType() : null;
                if (argTypeArray[i] == DispatchableObjectType)
                {
                    DispatchableObject v = (argArrayList[i] as DispatchableObject);
                    if (v.ByRef)
                    {
                        outArgs[i] = argArrayList[i];
                        hasOutValues = true;
                    }

                    argArrayList[i] = v.Value;
                }
            }
            if (!hasOutValues) outArgs = null;

            ConstructorInfo m = null;
            try
            {
                m = tClass.GetConstructor(argTypeArray);
            }
            catch (SystemException)
            {

            }

            if (m != null)
            {
                object[] invokeArgs = argArrayList.ToArray();
                object ret = m.Invoke(invokeArgs);
                if (outArgs != null) setOutValue(outArgs, invokeArgs);
                return WrapNonPrimitiveValueToAnyObjectRef(ret);
            }

            ConstructorInfo[] ms = tClass.GetConstructors();
            if(ms.Length==0 && tClass.IsValueType)
            {
                return WrapNonPrimitiveValueToAnyObjectRef( Activator.CreateInstance(tClass) );
            }

            bool failed = true;
            object[] invokeArgs2 = null;
            object ret2 = InvokeMemberBaseMethodInfo(".ctor", ms, argArrayList, ref failed, target, (int)BindingFlags.CreateInstance,ref invokeArgs2);
            if (!failed)
            {
                if (outArgs != null) setOutValue(outArgs, invokeArgs2);
                return WrapNonPrimitiveValueToAnyObjectRef(ret2);
            }

            invokeArgs2 = argArrayList.ToArray();
            ret2 = tClass.InvokeMember("", (BindingFlags)BindingFlags.CreateInstance | BindingFlags.IgnoreReturn, null, target, invokeArgs2);
            if (outArgs != null) setOutValue(outArgs, invokeArgs2);
            return WrapNonPrimitiveValueToAnyObjectRef(ret2);
        }

        private static bool IsNumericType(Type t)
        {
            switch (Type.GetTypeCode(t))
            {
                case TypeCode.Byte:
                case TypeCode.SByte:
                case TypeCode.UInt16:
                case TypeCode.UInt32:
                case TypeCode.UInt64:
                case TypeCode.Int16:
                case TypeCode.Int32:
                case TypeCode.Int64:
                case TypeCode.Decimal:
                case TypeCode.Double:
                case TypeCode.Single:
                    return true;
                default:
                    return false;
            }
        }
        
        static System.Drawing.Color ConvertNumToColor(object arg, TypeCode argTypeCode)
        {
            byte[] bytes;
            if (argTypeCode == TypeCode.Double) bytes = BitConverter.GetBytes((uint)Convert.ChangeType(arg, typeof(uint)));
            else bytes = BitConverter.GetBytes((int)arg);

            return System.Drawing.Color.FromArgb(bytes[3], bytes[2], bytes[1], bytes[0]);
        }

        private object InvokeMemberBaseMethodInfo(string methodName, MethodBase[] ms, ArrayList argArrayList, ref bool failed, object target, int invokeAttr, ref object[] invokeArgs2)
        {

            for (int i = 0; i < ms.Length; i++)
            {
                if ((ms[i].Name != methodName) || ms[i].IsGenericMethod) continue;
                var parameters = ms[i].GetParameters();

                if (parameters.Length == argArrayList.Count)
                {
                    failed = false;
                    for (int k = 0; k < parameters.Length; k++)
                    {
                        var paramType = parameters[k].ParameterType;
                        Type nullableUnderlyingType = Nullable.GetUnderlyingType(paramType);
                        if (argArrayList[k] == null)
                        {
                            if (!paramType.IsValueType || nullableUnderlyingType != null)
                                continue;

                            failed = true;
                            break;
                        }

                        if (nullableUnderlyingType != null)
                        {
                            paramType = nullableUnderlyingType;
                        }

                        var argType = argArrayList[k].GetType();
                        if (paramType.IsAssignableFrom(argType)) continue;

                        Type enumType = null;
                        if (paramType.IsEnum)
                        {
                            enumType = paramType;
                            paramType = Enum.GetUnderlyingType(enumType);
                        }

                        //string a = paramType.Name;
                        if (!paramType.IsAssignableFrom(argType))
                        {
                            if (typeof(Delegate).IsAssignableFrom(paramType) && (argType == null) || argType.IsCOMObject)
                            {
                                if (argType != null)
                                {
                                    var dd = new DispatchableDelegate(argArrayList[k]);
                                    argArrayList[k] = (object)dd.CreateDelegate(paramType);
                                }
                                
                            }
                            else
                            {
                                failed = true;
                                break;
                            }
                        }
                        else if (enumType != null) argArrayList[k] = Enum.ToObject(enumType, argArrayList[k]);
                    }

                    if (!failed)
                    {
                        invokeArgs2 = argArrayList.ToArray();
                        if (methodName == ".ctor") return (ms[i] as ConstructorInfo).Invoke(invokeArgs2);
                        return ms[i].Invoke(target, (BindingFlags)invokeAttr, null, invokeArgs2, null);
                    }
                }
            }

            for (int i = 0; i < ms.Length; i++)
            {
                if ((ms[i].Name != methodName) || ms[i].IsGenericMethod) continue;

                var parameters = ms[i].GetParameters();
                if (parameters.Length > argArrayList.Count)
                {
                    failed = false;
                    for (int k = 0; k < argArrayList.Count; k++)
                    {
                        var paramType = parameters[k].ParameterType;
                        Type nullableUnderlyingType = Nullable.GetUnderlyingType(paramType);
                        if (argArrayList[k] == null)
                        {
                            if (!paramType.IsValueType || nullableUnderlyingType != null)
                                continue;

                            failed = true;
                            break;
                        }

                        if (nullableUnderlyingType != null)
                        {
                            paramType = nullableUnderlyingType;
                        }

                        var argType = argArrayList[k].GetType();
                        if (paramType.IsAssignableFrom(argType)) continue;

                        Type enumType = null;
                        if (paramType.IsEnum)
                        {
                            enumType = paramType;
                            paramType = Enum.GetUnderlyingType(enumType);
                        }

                        if (!paramType.IsAssignableFrom(argType))
                        {
                            if (typeof(Delegate).IsAssignableFrom(paramType) && (argType == null) || argType.IsCOMObject)
                            {
                                if (argType != null)
                                {
                                    var dd = new DispatchableDelegate(argArrayList[k]);
                                    argArrayList[k] = (object)dd.CreateDelegate(paramType);
                                }  
                            }
                            else
                            {
                                failed = true;
                                break;
                            }
                        }
                        else if (enumType != null && !(argType.IsEnum)) argArrayList[k] = Enum.ToObject(enumType, argArrayList[k]);
                    }

                    ArrayList argList2 = argArrayList.Clone() as ArrayList;
                    for (int k = argArrayList.Count; k < parameters.Length; k++)
                    {
                        if (!parameters[k].IsOptional)
                        {
                            failed = true;
                            break;
                        }

                        argList2.Add(parameters[k].DefaultValue);
                    }

                    if (!failed)
                    {
                        invokeArgs2 = argList2.ToArray();
                        if (methodName == ".ctor") return (ms[i] as ConstructorInfo).Invoke(invokeArgs2);
                        return ms[i].Invoke(target, (BindingFlags)invokeAttr, null, invokeArgs2, null);
                    }
                }
            }

            for (int i = 0; i < ms.Length; i++)
            {
                if ((ms[i].Name != methodName) || ms[i].IsGenericMethod) continue;

                var parameters = ms[i].GetParameters();
                if (parameters.Length == argArrayList.Count)
                {
                    failed = false;
                    for (int k = 0; k < parameters.Length; k++)
                    {
                        var paramType = parameters[k].ParameterType;
                        Type nullableUnderlyingType = Nullable.GetUnderlyingType(paramType);
                        if (argArrayList[k] == null)
                        {
                            if (!paramType.IsValueType || nullableUnderlyingType != null)
                                continue;

                            failed = true;
                            break;
                        }

                        if (nullableUnderlyingType != null)
                        {
                            paramType = nullableUnderlyingType;
                        }

                        var argType = argArrayList[k].GetType();
                        if (paramType.IsAssignableFrom(argType)) continue;

                        Type enumType = null;
                        if (paramType.IsEnum)
                        {
                            enumType = paramType;
                            paramType = Enum.GetUnderlyingType(enumType);
                        }

                        //string a = paramType.Name;
                        if (!paramType.IsAssignableFrom(argType))
                        {
                            if (typeof(Delegate).IsAssignableFrom(paramType) && (argType == null) || argType.IsCOMObject)
                            {
                                if (argType != null)
                                {
                                    var dd = new DispatchableDelegate(argArrayList[k]);
                                    argArrayList[k] = (object)dd.CreateDelegate(paramType);
                                }
                                continue;
                            }

                            var paramTypeCode = Type.GetTypeCode(paramType);
                            var argTypeCode = Type.GetTypeCode(argType);

                            if (argTypeCode == TypeCode.Double || argTypeCode == TypeCode.Int32)
                            {

                                if (IsNumericType(paramType))
                                {
                                    argArrayList[k] = Convert.ChangeType(argArrayList[k], paramType);
                                    if (enumType != null && !(argType.IsEnum)) argArrayList[k] = Enum.ToObject(enumType, argArrayList[k]);
                                    continue;
                                }
                                else if (paramType == ColorType)
                                {
                                    argArrayList[k] = ConvertNumToColor(argArrayList[k], argTypeCode);
                                    if (enumType != null && !(argType.IsEnum)) argArrayList[k] = Enum.ToObject(enumType, argArrayList[k]);
                                    continue;
                                }
                                else if (paramType == IntPtrType && argTypeCode == TypeCode.Int32)
                                {
                                    argArrayList[k] = new System.IntPtr((int)argArrayList[k]);
                                    if (enumType != null && !(argType.IsEnum)) argArrayList[k] = Enum.ToObject(enumType, argArrayList[k]);
                                    continue;
                                }
                                else if (paramType == UIntPtrType && argTypeCode == TypeCode.Int32)
                                {
                                    argArrayList[k] = new System.UIntPtr((uint)(int)argArrayList[k]);
                                    if (enumType != null && !(argType.IsEnum)) argArrayList[k] = Enum.ToObject(enumType, argArrayList[k]);
                                    continue;
                                }
                            }
                            else if (paramType.IsArray && argType.IsArray)
                            {
                                var paramEleType = paramType.GetElementType();
                                var argEleType = argType.GetElementType();
                                var argEleTypeCode = Type.GetTypeCode(argEleType);

                                if ((argEleTypeCode == TypeCode.Double) && IsNumericType(paramEleType))
                                {

                                    var srcArr = (argArrayList[k] as double[]);
                                    var dstArr = Array.CreateInstance(paramEleType, srcArr.Length);
                                    for (int n = 0; n < srcArr.Length; n++)
                                    {
                                        dstArr.SetValue(Convert.ChangeType(srcArr[n], paramEleType), n);
                                    }

                                    argArrayList[k] = dstArr;
                                    continue;
                                }

                            }

                            failed = true;
                            break;
                        }

                        if (enumType != null && !(argType.IsEnum)) argArrayList[k] = Enum.ToObject(enumType, argArrayList[k]);
                    }

                    if (!failed)
                    {
                        invokeArgs2 = argArrayList.ToArray();
                        if (methodName == ".ctor") return (ms[i] as ConstructorInfo).Invoke(invokeArgs2);
                        return ms[i].Invoke(target, (BindingFlags)invokeAttr, null, invokeArgs2, null);
                    }
                }
            }

            for (int i = 0; i < ms.Length; i++)
            {
                if ((ms[i].Name != methodName) || ms[i].IsGenericMethod) continue;

                var parameters = ms[i].GetParameters();
                if (parameters.Length > argArrayList.Count)
                {
                    failed = false;
                    for (int k = 0; k < argArrayList.Count; k++)
                    {
                        var paramType = parameters[k].ParameterType;
                        Type nullableUnderlyingType = Nullable.GetUnderlyingType(paramType);
                        if (argArrayList[k] == null)
                        {
                            if (!paramType.IsValueType || nullableUnderlyingType != null)
                                continue;

                            failed = true;
                            break;
                        }

                        if (nullableUnderlyingType != null)
                        {
                            paramType = nullableUnderlyingType;
                        }

                        var argType = argArrayList[k].GetType();
                        if (paramType.IsAssignableFrom(argType)) continue;

                        Type enumType = null;
                        if (paramType.IsEnum)
                        {
                            enumType = paramType;
                            paramType = Enum.GetUnderlyingType(enumType);
                        }

                        if (!paramType.IsAssignableFrom(argType))
                        {
                            if (typeof(Delegate).IsAssignableFrom(paramType) && (argType == null) || argType.IsCOMObject)
                            {
                                if (argType != null)
                                {
                                    var dd = new DispatchableDelegate(argArrayList[k]);
                                    argArrayList[k] = (object)dd.CreateDelegate(paramType);
                                }
                            }
                            else
                            {

                                var paramTypeCode = Type.GetTypeCode(paramType);
                                var argTypeCode = Type.GetTypeCode(argType);

                                if (argTypeCode == TypeCode.Double || argTypeCode == TypeCode.Int32)
                                {

                                    if (IsNumericType(paramType))
                                    {
                                        argArrayList[k] = Convert.ChangeType(argArrayList[k], paramType);
                                        if (enumType != null && !(argType.IsEnum)) argArrayList[k] = Enum.ToObject(enumType, argArrayList[k]);
                                        continue;
                                    }
                                    else if (paramType == ColorType)
                                    {
                                        argArrayList[k] = ConvertNumToColor(argArrayList[k], argTypeCode);
                                        if (enumType != null && !(argType.IsEnum)) argArrayList[k] = Enum.ToObject(enumType, argArrayList[k]);
                                        continue;
                                    }
                                    else if (paramType == IntPtrType && argTypeCode == TypeCode.Int32)
                                    {
                                        argArrayList[k] = new System.IntPtr((int)argArrayList[k]);
                                        if (enumType != null && !(argType.IsEnum)) argArrayList[k] = Enum.ToObject(enumType, argArrayList[k]);
                                        continue;
                                    }
                                    else if (paramType == UIntPtrType && argTypeCode == TypeCode.Int32)
                                    {
                                        argArrayList[k] = new System.UIntPtr((uint)(int)argArrayList[k]);
                                        if (enumType != null && !(argType.IsEnum)) argArrayList[k] = Enum.ToObject(enumType, argArrayList[k]);
                                        continue;
                                    }
                                }
                                else if (paramType.IsArray && argType.IsArray)
                                {
                                    var paramEleType = paramType.GetElementType();
                                    var argEleType = argType.GetElementType();
                                    var argEleTypeCode = Type.GetTypeCode(argEleType);

                                    if ((argEleTypeCode == TypeCode.Double) && IsNumericType(paramEleType))
                                    {

                                        var srcArr = (argArrayList[k] as double[]);
                                        var dstArr = Array.CreateInstance(paramEleType, srcArr.Length);
                                        for (int n = 0; n < srcArr.Length; n++)
                                        {
                                            dstArr.SetValue(Convert.ChangeType(srcArr[n], paramEleType), n);
                                        }

                                        argArrayList[k] = dstArr;
                                        continue;
                                    }

                                }

                                failed = true;
                                break;
                            }
                        }
                        else if (enumType != null && !(argType.IsEnum)) argArrayList[k] = Enum.ToObject(enumType, argArrayList[k]);
                    }

                    ArrayList argList2 = argArrayList.Clone() as ArrayList;
                    for (int k = argArrayList.Count; k < parameters.Length; k++)
                    {
                        if (!parameters[k].IsOptional)
                        {
                            failed = true;
                            break;
                        }

                        argList2.Add(parameters[k].DefaultValue);
                    }

                    if (!failed)
                    {
                        invokeArgs2 = argList2.ToArray();
                        if (methodName == ".ctor") return (ms[i] as ConstructorInfo).Invoke(invokeArgs2);
                        return ms[i].Invoke(target, (BindingFlags)invokeAttr, null, invokeArgs2, null);
                    }
                }
            }

            for (int i = 0; i < ms.Length; i++)
            {
                if (ms[i] is MethodInfo method) {  
                    var methodParameters = method.GetParameters(); 
                    if (method.Name == methodName && argArrayList.Count <= methodParameters.Length)
                    {
                        if (!method.IsGenericMethod) continue;

                        var genericArguments = method.GetGenericArguments();
                        var genericParameters = new Type[genericArguments.Length];  
                        int genericArgumentIndex;
                             
                        for (int k = 0; k < argArrayList.Count; k++)
                        {
                            var argType = argArrayList[k].GetType();
                            genericArgumentIndex = Array.IndexOf(genericArguments, methodParameters[k].ParameterType);

                            if (genericArgumentIndex == -1) continue;
                            genericParameters[genericArgumentIndex] = argType;
                        }

                        if (Array.IndexOf(genericParameters, null) != -1)
                        {
                            continue;
                        }

                        if (argArrayList.Count < methodParameters.Length  )
                        {

                            ArrayList argList2 = argArrayList.Clone() as ArrayList;
                            bool isOptionalFailed = false;
                            for (int k = argArrayList.Count; k < methodParameters.Length; k++)
                            {
                                if (!methodParameters[k].IsOptional)
                                {
                                    isOptionalFailed = true;
                                    break;
                                }

                                argList2.Add(methodParameters[k].DefaultValue);
                            }
                            if (isOptionalFailed) continue;

                            var concreteMethod = method.MakeGenericMethod(genericParameters);

                            failed = false;
                            invokeArgs2 = argList2.ToArray();
                            return concreteMethod.Invoke(target, (BindingFlags)invokeAttr, null, invokeArgs2, null);
                        }
                        else
                        {
                            var concreteMethod = method.MakeGenericMethod(genericParameters);

                            failed = false;
                            invokeArgs2 = argArrayList.ToArray();
                            return concreteMethod.Invoke(target, (BindingFlags)invokeAttr, null, invokeArgs2, null);
                        }
                    }
                }
            }


            for (int i = 0; i < ms.Length; i++)
            {
                if (ms[i].Name == methodName && ms[i].GetParameters().Length == argArrayList.Count)
                {
                    if (!ms[i].IsGenericMethod)
                    {
                        failed = false;
                        invokeArgs2 = argArrayList.ToArray();
                        if (methodName == ".ctor") return (ms[i] as ConstructorInfo).Invoke(invokeArgs2);
                        return ms[i].Invoke(target, (BindingFlags)invokeAttr, null, invokeArgs2, null);
                    }
                }
            }
            

            failed = true;
            return null;
        }

        public Object InvokeEnumValue(object enumType, string methodName)
        {
            return System.Enum.Parse(enumType as Type, methodName);
        }

  

        public Object InvokeEnumType(object assemblyName, string nameSpace, string enumTypeName)
        {
            Assembly assembly = assemblyName as Assembly;
            if (assembly == null)
            {
                assembly = this.loadAssembly(assemblyName as string);
            }
            if (assembly != null)
            {
                string fullTypeName = null;
                if (nameSpace != null)
                {
                    try
                    {
                        Type nsType = assembly.GetType(nameSpace);
                        if (nsType.IsClass)
                        {
                            fullTypeName = nameSpace + "+" + enumTypeName;
                        }
                        else
                        {
                            fullTypeName = nameSpace + "." + enumTypeName;
                        }
                    }
                    catch (SystemException)
                    {
                        fullTypeName = nameSpace + "." + enumTypeName;
                    }
                }

                Type t = assembly.GetType(fullTypeName);
                if (t.IsEnum)
                {
                    return t as object;
                }
            }
            return null;
        }


        public Object ParseEnum(object assemblyName, string nameSpace, string enumTypeName, string methodName)
        {
            Assembly assembly = assemblyName as Assembly;
            if (assembly == null)
            {
                assembly = this.loadAssembly(assemblyName as string);
            }
            if (assembly != null)
            {
                string fullTypeName = null;
                if (nameSpace != null)
                {
                    try
                    {
                        Type nsType = assembly.GetType(nameSpace);
                        if (nsType.IsClass)
                        {
                            fullTypeName = nameSpace + "+" + enumTypeName;
                        }
                        else
                        {
                            fullTypeName = nameSpace + "." + enumTypeName;
                        }
                    }
                    catch (SystemException)
                    {
                        fullTypeName = nameSpace + "." + enumTypeName;
                    }
                }

                Type t = assembly.GetType(fullTypeName);
                if (t.IsEnum)
                {
                    return System.Enum.Parse(t, methodName);
                }
            }
            return null;
        }

        public Assembly loadAssembly(string assemblyName)
        {
            try
            {
                Assembly assembly = Assembly.LoadWithPartialName(assemblyName);
                Assembly result = assembly;
                return result;
            }
            catch (SystemException)
            {
            }
            try
            {
                Assembly assembly2 = Assembly.Load(AssemblyName.GetAssemblyName(assemblyName));
                Assembly result = assembly2;
                return result;
            }
            catch (SystemException)
            {
            }
            try
            {
                Assembly assembly3 = Assembly.LoadFrom(assemblyName);
                Assembly result = assembly3;
                return result;
            }
            catch (SystemException)
            {
            }
            try
            {
                Assembly assembly4 = Assembly.LoadFile(assemblyName);
                Assembly result = assembly4;
                return result;
            }
            catch (SystemException)
            {
            }
            return null;
        }

        public class NameValue<TK,TV>
        {
            public TK Name { get; private set; }
            public TV Value { get; private set; }
            public NameValue(TK name, TV value)
            {
                Name = name;
                Value = value;
            } 
        }

        [ ComVisible(false)]
        private object NameValueList2(object nameList, object valueList)
        {
            if (nameList is DispatchableObject n) nameList = n.Value;
            if (valueList is DispatchableObject v) valueList = v.Value;

            Array names = (nameList as Array);
            Array values = (valueList as Array);

            Type NameValueConstructed = typeof(NameValue<,>).MakeGenericType(new Type[] { names.GetValue(0).GetType(), values.GetValue(0).GetType() });
            Type NameValueListConstructed = typeof(List<>).MakeGenericType(new Type[] { NameValueConstructed });

            IList o = (IList)Activator.CreateInstance(NameValueListConstructed);

            for (int i = 0; i < names.Length; i++)
            {
                o.Add( Activator.CreateInstance(NameValueConstructed, new object[] { names.GetValue(i), values.GetValue(i) }));
            }

            return o;
        }

        public object NameValueList(object nameList,object valueList)
        { 

            return NameValueList2(nameList, valueList);
        } 

        public void ReopenConsole(bool utf8)
		{
			if(utf8){
				TextWriter writer = new StreamWriter(Console.OpenStandardOutput())
				{ AutoFlush = true };
				Console.SetOut(writer);
	
				TextWriter writerErr = new StreamWriter(Console.OpenStandardError())
				{ AutoFlush = true };
				Console.SetError(writerErr);
	
				TextReader reader = new StreamReader(Console.OpenStandardInput());
				Console.SetIn(reader);
			}
			else {
				TextWriter writer = new StreamWriter(Console.OpenStandardOutput(),System.Text.Encoding.Default )
				{ AutoFlush = true };
				Console.SetOut(writer);
	
				TextWriter writerErr = new StreamWriter(Console.OpenStandardError(),System.Text.Encoding.Default )
				{ AutoFlush = true };
				Console.SetError(writerErr);
	
				TextReader reader = new StreamReader(Console.OpenStandardInput(),System.Text.Encoding.Default );
				Console.SetIn(reader);
			}
				
		}

    }
}
