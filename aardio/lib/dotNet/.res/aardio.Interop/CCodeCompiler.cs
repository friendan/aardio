﻿/*
可遵循 aardio 用户协议与 aardio 开源许可证在 aardio 程序中自由使用本组件以及本组件源码,
禁止在非 aardio 开发的程序中引用本组件的任何部份(包含但不限于本组件源码、使用此源码生成的 DLL )
*/
using System;
using System.CodeDom.Compiler;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;
using System.IO;
using System.Web.Services.Description;
using Microsoft.CSharp;
using System.Net;

namespace aardio.Interop
{
	[ClassInterface(ClassInterfaceType.AutoDispatch), ComVisible(true)]
	public class CCodeCompiler
	{
		private StringBuilder lastErrorText;

		private CompilerParameters parameters;

		private CodeDomProvider provider;

		private object source;

		public string LastError
		{
			get
			{
				return this.lastErrorText.ToString();
			}
		}

		public CompilerParameters Parameters
		{
			get
			{
				return this.parameters;
			}
			set
			{
				this.parameters = value;
			}
		}

		public CodeDomProvider Provider
		{
			get
			{
				return this.provider;
			}
			set
			{
				this.provider = value;
			}
		}

		public object Source
		{
			get
			{
				return this.source;
			}
			set
			{
				this.source = value;
			}
		} 

        public CCodeCompiler(CodeDomProvider p)
		{
			this.provider = p;
			this.parameters = new CompilerParameters();
			this.parameters.ReferencedAssemblies.Add("System.dll");
			this.parameters.GenerateExecutable = false;
			this.parameters.GenerateInMemory = true;
			this.lastErrorText = new StringBuilder();
			this.source = null;
		}

		public Assembly Compile()
		{
			this.lastErrorText = new StringBuilder();

			string[] source;
			if (this.Source is string) source = new string[] { this.Source as string };
			else source = this.Source as string[];
			 
			if (source == null)
			{
				this.lastErrorText.Append("Property 'Source' cannot be null!");
				return null;
			}

            CompilerResults compilerResults = this.provider.CompileAssemblyFromSource(this.parameters, source);
			if (!compilerResults.Errors.HasErrors)
			{
				return compilerResults.CompiledAssembly;
			}
			foreach (CompilerError compilerError in compilerResults.Errors)
			{
				this.lastErrorText.Append(string.Format("ErrorNumber:{0} Line:{1} {2}", compilerError.ErrorNumber, compilerError.Line, compilerError.ErrorText));
				this.lastErrorText.Append("\r\n");
			}
			return null;
		}

		public Assembly CompileWebService(string url, string ns, string protocolName)
		{
			this.lastErrorText = new StringBuilder();
			if (url == null)
			{
				this.lastErrorText.Append("未指定服务地址!");
				return null;
			}

			WebClient http = new WebClient();
			Stream stream = http.OpenRead(url + "?WSDL");
			ServiceDescription serviceDesc = ServiceDescription.Read(stream);
			ServiceDescriptionImporter sdImporter = new ServiceDescriptionImporter();
			sdImporter.ProtocolName = protocolName;
			sdImporter.AddServiceDescription(serviceDesc, "", "");

			foreach (Import schemaImport in serviceDesc.Imports)
			{
				Uri baseUri = new Uri(url + "?WSDL");
				string schemaLocation = schemaImport.Location;
				if (schemaLocation == null)
					continue;
				Uri schemaUri = new Uri(baseUri, schemaLocation);

				using (Stream schemaStream = http.OpenRead(schemaUri))
				{
					try
					{
						ServiceDescription sdImport = ServiceDescription.Read(schemaStream, true);
						sdImport.Namespaces.Add("wsdl", schemaImport.Namespace);
						sdImporter.AddServiceDescription(sdImport, null, null);
					}
					catch { }
				}
			}
		
			foreach (System.Xml.Schema.XmlSchema wsdlSchema in serviceDesc.Types.Schemas)
			{
				foreach (System.Xml.Schema.XmlSchemaObject externalSchema in wsdlSchema.Includes)
				{
					if (externalSchema is System.Xml.Schema.XmlSchemaImport)
					{
						Uri baseUri = new Uri(url + "?WSDL");
						string exSchemaLocation = ((System.Xml.Schema.XmlSchemaExternal)externalSchema).SchemaLocation;
						if (string.IsNullOrEmpty(exSchemaLocation))
							continue;

						Uri schemaUri = new Uri(baseUri, exSchemaLocation);

						using (Stream schemaStream = http.OpenRead(schemaUri))
						{
							try
							{
								System.Xml.Schema.XmlSchema schema = System.Xml.Schema.XmlSchema.Read(schemaStream, null);
								sdImporter.Schemas.Add(schema);
							}
							catch { }                                                      
						}
					}
				}
			}


			System.CodeDom.CodeNamespace codeNamespace = new System.CodeDom.CodeNamespace(ns);
			System.CodeDom.CodeCompileUnit codeCompileUnit = new System.CodeDom.CodeCompileUnit();
			codeCompileUnit.Namespaces.Add(codeNamespace);
			sdImporter.Import(codeNamespace, codeCompileUnit);

			this.parameters.ReferencedAssemblies.Add("System.XML.dll");
			this.parameters.ReferencedAssemblies.Add("System.Web.Services.dll");
			this.parameters.ReferencedAssemblies.Add("System.Data.dll");
			CompilerResults compilerResults = this.provider.CompileAssemblyFromDom(this.parameters, codeCompileUnit);

			if (true == compilerResults.Errors.HasErrors)
			{
				foreach (CompilerError compilerError in compilerResults.Errors)
				{
					this.lastErrorText.Append(string.Format("ErrorNumber:{0} Line:{1} {2}", compilerError.ErrorNumber, compilerError.Line, compilerError.ErrorText));
					this.lastErrorText.Append("\r\n");
				}
				return null;
			}

			return compilerResults.CompiledAssembly; 
				
		}

		public void Reference(string assemblyName)
		{
			this.parameters.ReferencedAssemblies.Add(assemblyName);
		}
	}
}
