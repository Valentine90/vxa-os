namespace Account_Editor
{
    partial class frmEditor
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmEditor));
            this.grpAccount = new System.Windows.Forms.GroupBox();
            this.btnSearch = new System.Windows.Forms.Button();
            this.txtName = new System.Windows.Forms.TextBox();
            this.lblName = new System.Windows.Forms.Label();
            this.grpData = new System.Windows.Forms.GroupBox();
            this.nudVip = new System.Windows.Forms.NumericUpDown();
            this.lblVip = new System.Windows.Forms.Label();
            this.lstChars = new System.Windows.Forms.ListBox();
            this.cboGroup = new System.Windows.Forms.ComboBox();
            this.txtEmail = new System.Windows.Forms.TextBox();
            this.txtPass = new System.Windows.Forms.TextBox();
            this.lblChars = new System.Windows.Forms.Label();
            this.lblGroup = new System.Windows.Forms.Label();
            this.lblEmail = new System.Windows.Forms.Label();
            this.lblPass = new System.Windows.Forms.Label();
            this.btnSave = new System.Windows.Forms.Button();
            this.btnClear = new System.Windows.Forms.Button();
            this.grpAccount.SuspendLayout();
            this.grpData.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.nudVip)).BeginInit();
            this.SuspendLayout();
            // 
            // grpAccount
            // 
            this.grpAccount.Controls.Add(this.btnSearch);
            this.grpAccount.Controls.Add(this.txtName);
            this.grpAccount.Controls.Add(this.lblName);
            this.grpAccount.Location = new System.Drawing.Point(12, 12);
            this.grpAccount.Name = "grpAccount";
            this.grpAccount.Size = new System.Drawing.Size(263, 57);
            this.grpAccount.TabIndex = 1;
            this.grpAccount.TabStop = false;
            this.grpAccount.Text = "Conta";
            // 
            // btnSearch
            // 
            this.btnSearch.Location = new System.Drawing.Point(194, 20);
            this.btnSearch.Name = "btnSearch";
            this.btnSearch.Size = new System.Drawing.Size(57, 22);
            this.btnSearch.TabIndex = 2;
            this.btnSearch.Text = "Buscar";
            this.btnSearch.UseVisualStyleBackColor = true;
            this.btnSearch.Click += new System.EventHandler(this.btnSearch_Click);
            // 
            // txtName
            // 
            this.txtName.Location = new System.Drawing.Point(52, 22);
            this.txtName.Name = "txtName";
            this.txtName.Size = new System.Drawing.Size(136, 20);
            this.txtName.TabIndex = 1;
            this.txtName.KeyPress += new System.Windows.Forms.KeyPressEventHandler(this.txtName_KeyPress);
            // 
            // lblName
            // 
            this.lblName.AutoSize = true;
            this.lblName.Location = new System.Drawing.Point(8, 25);
            this.lblName.Name = "lblName";
            this.lblName.Size = new System.Drawing.Size(38, 13);
            this.lblName.TabIndex = 0;
            this.lblName.Text = "Nome:";
            // 
            // grpData
            // 
            this.grpData.Controls.Add(this.nudVip);
            this.grpData.Controls.Add(this.lblVip);
            this.grpData.Controls.Add(this.lstChars);
            this.grpData.Controls.Add(this.cboGroup);
            this.grpData.Controls.Add(this.txtEmail);
            this.grpData.Controls.Add(this.txtPass);
            this.grpData.Controls.Add(this.lblChars);
            this.grpData.Controls.Add(this.lblGroup);
            this.grpData.Controls.Add(this.lblEmail);
            this.grpData.Controls.Add(this.lblPass);
            this.grpData.Enabled = false;
            this.grpData.Location = new System.Drawing.Point(12, 75);
            this.grpData.Name = "grpData";
            this.grpData.Size = new System.Drawing.Size(263, 243);
            this.grpData.TabIndex = 2;
            this.grpData.TabStop = false;
            this.grpData.Text = "Dados";
            // 
            // nudVip
            // 
            this.nudVip.Location = new System.Drawing.Point(72, 106);
            this.nudVip.Name = "nudVip";
            this.nudVip.Size = new System.Drawing.Size(179, 20);
            this.nudVip.TabIndex = 7;
            // 
            // lblVip
            // 
            this.lblVip.AutoSize = true;
            this.lblVip.Location = new System.Drawing.Point(6, 106);
            this.lblVip.Name = "lblVip";
            this.lblVip.Size = new System.Drawing.Size(51, 13);
            this.lblVip.TabIndex = 8;
            this.lblVip.Text = "Dias VIP:";
            // 
            // lstChars
            // 
            this.lstChars.FormattingEnabled = true;
            this.lstChars.Location = new System.Drawing.Point(73, 133);
            this.lstChars.Name = "lstChars";
            this.lstChars.Size = new System.Drawing.Size(178, 95);
            this.lstChars.TabIndex = 10;
            // 
            // cboGroup
            // 
            this.cboGroup.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.cboGroup.FormattingEnabled = true;
            this.cboGroup.Items.AddRange(new object[] {
            "Normal",
            "Monitor",
            "Administrador"});
            this.cboGroup.Location = new System.Drawing.Point(72, 79);
            this.cboGroup.Name = "cboGroup";
            this.cboGroup.Size = new System.Drawing.Size(179, 21);
            this.cboGroup.TabIndex = 6;
            // 
            // txtEmail
            // 
            this.txtEmail.Location = new System.Drawing.Point(73, 53);
            this.txtEmail.Name = "txtEmail";
            this.txtEmail.Size = new System.Drawing.Size(178, 20);
            this.txtEmail.TabIndex = 5;
            // 
            // txtPass
            // 
            this.txtPass.Location = new System.Drawing.Point(73, 27);
            this.txtPass.Name = "txtPass";
            this.txtPass.Size = new System.Drawing.Size(178, 20);
            this.txtPass.TabIndex = 4;
            // 
            // lblChars
            // 
            this.lblChars.AutoSize = true;
            this.lblChars.Location = new System.Drawing.Point(6, 133);
            this.lblChars.Name = "lblChars";
            this.lblChars.Size = new System.Drawing.Size(40, 13);
            this.lblChars.TabIndex = 3;
            this.lblChars.Text = "Heróis:";
            // 
            // lblGroup
            // 
            this.lblGroup.AutoSize = true;
            this.lblGroup.Location = new System.Drawing.Point(6, 79);
            this.lblGroup.Name = "lblGroup";
            this.lblGroup.Size = new System.Drawing.Size(39, 13);
            this.lblGroup.TabIndex = 2;
            this.lblGroup.Text = "Grupo:";
            // 
            // lblEmail
            // 
            this.lblEmail.AutoSize = true;
            this.lblEmail.Location = new System.Drawing.Point(6, 53);
            this.lblEmail.Name = "lblEmail";
            this.lblEmail.Size = new System.Drawing.Size(38, 13);
            this.lblEmail.TabIndex = 1;
            this.lblEmail.Text = "E-mail:";
            // 
            // lblPass
            // 
            this.lblPass.AutoSize = true;
            this.lblPass.Location = new System.Drawing.Point(6, 30);
            this.lblPass.Name = "lblPass";
            this.lblPass.Size = new System.Drawing.Size(68, 13);
            this.lblPass.TabIndex = 0;
            this.lblPass.Text = "Nova senha:";
            // 
            // btnSave
            // 
            this.btnSave.Location = new System.Drawing.Point(12, 324);
            this.btnSave.Name = "btnSave";
            this.btnSave.Size = new System.Drawing.Size(127, 29);
            this.btnSave.TabIndex = 3;
            this.btnSave.Text = "Salvar";
            this.btnSave.UseVisualStyleBackColor = true;
            this.btnSave.Click += new System.EventHandler(this.btnSave_Click);
            // 
            // btnClear
            // 
            this.btnClear.Location = new System.Drawing.Point(148, 324);
            this.btnClear.Name = "btnClear";
            this.btnClear.Size = new System.Drawing.Size(127, 29);
            this.btnClear.TabIndex = 4;
            this.btnClear.Text = "Limpar";
            this.btnClear.UseVisualStyleBackColor = true;
            this.btnClear.Click += new System.EventHandler(this.btnClear_Click);
            // 
            // frmEditor
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(288, 361);
            this.Controls.Add(this.btnClear);
            this.Controls.Add(this.btnSave);
            this.Controls.Add(this.grpData);
            this.Controls.Add(this.grpAccount);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MaximizeBox = false;
            this.Name = "frmEditor";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Editor de contas";
            this.grpAccount.ResumeLayout(false);
            this.grpAccount.PerformLayout();
            this.grpData.ResumeLayout(false);
            this.grpData.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.nudVip)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion
        private System.Windows.Forms.GroupBox grpAccount;
        private System.Windows.Forms.GroupBox grpData;
        private System.Windows.Forms.TextBox txtName;
        private System.Windows.Forms.Label lblName;
        private System.Windows.Forms.Label lblChars;
        private System.Windows.Forms.Label lblGroup;
        private System.Windows.Forms.Label lblEmail;
        private System.Windows.Forms.Label lblPass;
        private System.Windows.Forms.ComboBox cboGroup;
        private System.Windows.Forms.TextBox txtEmail;
        private System.Windows.Forms.TextBox txtPass;
        private System.Windows.Forms.ListBox lstChars;
        private System.Windows.Forms.Button btnSearch;
        private System.Windows.Forms.Label lblVip;
        private System.Windows.Forms.NumericUpDown nudVip;
        private System.Windows.Forms.Button btnSave;
        private System.Windows.Forms.Button btnClear;
    }
}

