using System;
using System.Collections.Generic;
using System.Security.Cryptography;
using System.Text;
using System.Windows.Forms;
using System.IO;

namespace Account_Editor
{
    public partial class frmEditor : Form
    {
        private string user;
        private string pass;
        private string email;
        private byte group;
        private Dictionary<byte, string> actors;
        private DateTime vipTime;
        private string[] friends;

        public frmEditor()
        {
            InitializeComponent();
            cboGroup.SelectedIndex = 0;
            actors = new Dictionary<byte, string>();
        }

        private string GetMd5Hash(string input)
        {
            var md5Hash = MD5.Create();
            var sBuilder = new StringBuilder();

            byte[] data = md5Hash.ComputeHash(Encoding.UTF8.GetBytes(input));

            for (int i = 0; i < data.Length; i++)
            {
                sBuilder.Append(data[i].ToString("x2"));
            }
            return sBuilder.ToString();
        }

        private void mnsExit_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }

        private void btnSearch_Click(object sender, EventArgs e)
        {
            Search();
        }

        private void txtName_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)Keys.Enter)
                Search();
        }

        private void Search()
        {
            if (txtName.Text.Length == 0) return;
            var path = @"Data\Accounts\" + txtName.Text + ".bin";

            if (File.Exists(path))
            {
                grpData.Enabled = true;
                using (var reader = new BinaryReader(File.OpenRead(path)))
                {
                    user = txtName.Text;
                    var length = reader.ReadInt16();
                    pass = Encoding.UTF8.GetString(reader.ReadBytes(length));
                    length = reader.ReadInt16();
                    email = Encoding.UTF8.GetString(reader.ReadBytes(length));
                    group = reader.ReadByte();
                    vipTime = new DateTime(reader.ReadInt16(), reader.ReadByte(), reader.ReadByte());
                    var vipDays = (short)vipTime.Subtract(DateTime.Today).TotalDays;

                    length = reader.ReadByte();
                    friends = new string[length];
                    for (byte i = 0; i < friends.Length; i++)
                    {
                        length = reader.ReadInt16();
                        friends[i] = Encoding.UTF8.GetString(reader.ReadBytes(length));
                    }

                    actors.Clear();
                    byte index = 0;
                    var name = string.Empty;
                    lstChars.Items.Clear();
                    while (reader.PeekChar() != -1)
                    {
                        index = reader.ReadByte();
                        length = reader.ReadInt16();
                        name = Encoding.UTF8.GetString(reader.ReadBytes(length));
                        actors.Add(index, name);
                        lstChars.Items.Add(name);
                    }
                    if (vipDays > 0)
                        nudVip.Value = vipDays;
                    else
                        nudVip.Value = 0;
                    txtPass.Text = string.Empty;
                    txtEmail.Text = email;
                    cboGroup.SelectedIndex = group;
                }
            }
            else
            {
                MessageBox.Show("Esta conta não existe!");
                Clear();
            }
        }

        private void Clear()
        {
            grpData.Enabled = false;
            txtPass.Text = string.Empty;
            txtEmail.Text = string.Empty;
            nudVip.Value = 0;
            cboGroup.SelectedIndex = 0;
            lstChars.Items.Clear();
            user = string.Empty;
        }

        private void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(user)) return;
            var path = @"Data\Accounts\" + user + ".bin";

            using (var stream = new FileStream(path, FileMode.Create, FileAccess.Write))
            {
                using (var writer = new BinaryWriter(stream))
                //using (var writer = new BinaryWriter(File.OpenWrite(path)))
                {
                    if (txtPass.Text.Length > 0) pass = GetMd5Hash(txtPass.Text);
                    vipTime = DateTime.Now.AddDays((short)nudVip.Value);

                    writer.Write((short)Encoding.UTF8.GetByteCount(pass));
                    writer.Write(Encoding.UTF8.GetBytes(pass));
                    writer.Write((short)Encoding.UTF8.GetByteCount(txtEmail.Text));
                    writer.Write(Encoding.UTF8.GetBytes(txtEmail.Text));
                    writer.Write((byte)cboGroup.SelectedIndex);
                    writer.Write((short)vipTime.Year);
                    writer.Write((byte)vipTime.Month);
                    writer.Write((byte)vipTime.Day);
                    writer.Write((byte)friends.Length);
                    foreach (string friend in friends)
                    {
                        writer.Write((short)Encoding.UTF8.GetByteCount(friend));
                        writer.Write(Encoding.UTF8.GetBytes(friend));
                    }

                    foreach (KeyValuePair<byte, string> actor in actors)
                    {
                        writer.Write(actor.Key);
                        writer.Write((short)Encoding.UTF8.GetByteCount(actor.Value));
                        writer.Write(Encoding.UTF8.GetBytes(actor.Value));

                    }
                }
            }

            MessageBox.Show("Conta salva com sucesso!");
        }

        private void btnClear_Click(object sender, EventArgs e)
        {
            Clear();
            txtName.Text = string.Empty;
        }
    }
}
